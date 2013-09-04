package Cronin::Runner;
use 5.10.1;
use strict;
use warnings;

use Cronin;
use Getopt::Long qw(:config posix_default no_ignore_case bundling);
use Pod::Usage qw(pod2usage);
use AnyEvent::Util qw(run_cmd);
use Encode;
use Sys::Hostname;
use Module::Load;

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub new_with_options {
    my $class = shift;
    GetOptions(\my %opt,
        'sns:s',   # ARN
        'http:s',  # URL
        'email:s', # To
        'stdout!',
        'json!',
        'force-notify!',
        'help!',
        'version!',
    ) or pod2usage(1);
    $opt{help} and pod2usage(0);
    $opt{version} and $class->print_version;
    $opt{command} = shift @ARGV or pod2usage(1);
    $opt{argv} = \@ARGV;
    $class->new(%opt);
}

sub run {
    my $self = shift;
    my $db = Cronin->db;
    my $name = $self->command_to_name($self->{command});
    my $task = $db->find_or_create_task($name);
    my $log = $task->start({
        user     => $ENV{USER},
        hostname => hostname,
        argv     => $self->{argv},
    });
    my $outbuf = '';
    my $errbuf = '';
    my $buffer_size = Cronin->config->{buffer_size};
    my $cv = run_cmd [$self->{command}, @{$self->{argv}}],
        '>' => sub {
            my $out = shift // return;
            $outbuf .= decode_utf8($out);
            if (length $outbuf > $buffer_size) {
                $log->append_stdout($outbuf);
                $outbuf = '';
            }
        },
        '2>' => sub {
            my $err = shift // return;
            $errbuf .= decode_utf8($err);
            if (length $errbuf > $buffer_size) {
                $log->append_stderr($errbuf);
                $errbuf = '';
            }
        },
        '<' => \*STDIN,
        '$$' => \my $pid,
        'close_all' => 1;
    do {
        my $txn = $db->txn_scope;
        $task->write_pid($pid);
        $log->write_pid($pid);
        $txn->commit;
    };
    my $exit_code = $cv->recv;
    $exit_code >>= 8;
    $log->append_stdout($outbuf) if $outbuf;
    $log->append_stderr($errbuf) if $errbuf;
    if ($exit_code == 126 && length $log->stderr == 0) { # exec failed
        $log->append_stderr("cronin: command not found: $self->{command}\n");
    }
    do {
        my $txn = $db->txn_scope;
        $log->finish($exit_code);
        $task->finish;
        $txn->commit;
    };
    if ($exit_code or $self->{'force-notify'}) {
        $self->notify($task, $log);
    }
}

sub notify {
    my ($self, $task, $log) = @_;
    $task = $task->handle->find('tasks', $task->id);
    $log = $task->handle->find('logs', $log->id);
    exists $self->{sns}    and $self->do_notify('SNS', $self->{sns}, $task, $log);
    exists $self->{http}   and $self->do_notify('HTTP', $self->{http}, $task, $log);
    exists $self->{email}  and $self->do_notify('Email', $self->{email}, $task, $log);
    exists $self->{stdout} and $self->do_notify('STDOUT', $self->{stdout}, $task, $log);
}

sub do_notify {
    my ($self, $subclass, $target, $task, $log) = @_;
    my $class = "Cronin::Notify::$subclass";
    load $class;
    my $notifier = $class->new(
        task   => $task,
        log    => $log,
        target => $target,
        json   => $self->{json},
    );
    $notifier->notify;
}

sub command_to_name {
    my ($self, $command) = @_;
    my $root = $ENV{CRONIN_PROJECT_ROOT} or return $command;
    $root =~ s{/$}{};
    $command =~ s{^$root/}{};
    $command;
}

sub print_version {
    my $class = shift;
    say "Cronin $Cronin::VERSION";
    exit;
}

1;
__END__
