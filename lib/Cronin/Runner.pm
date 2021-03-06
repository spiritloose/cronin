package Cronin::Runner;
use 5.10.1;
use strict;
use warnings;

use Cronin;
use Cronin::Config;
use Getopt::Long qw(:config posix_default no_ignore_case bundling);
use Pod::Usage qw(pod2usage);
use AnyEvent::Util qw(run_cmd);
use Encode qw(find_encoding);
use Sys::Hostname;
use String::ShellQuote;
use Module::Load;

our $SSH_CMD = 'ssh';

sub new {
    my ($class, %args) = @_;
    bless \%args, $class;
}

sub new_with_options {
    my $class = shift;
    my %opt = (encoding => 'utf8');
    GetOptions(\%opt,
        'name:s',
        'host:s',
        'user:s',
        'sns:s',   # ARN
        'http:s',  # URL
        'email:s', # To
        'stdout!',
        'tee!',
        'json!',
        'force-notify!',
        'encoding=s',
        'help!',
        'version!',
    ) or pod2usage(1);
    $opt{help} and pod2usage(0);
    $opt{version} and $class->print_version;
    @ARGV or pod2usage(1);
    $opt{command} = \@ARGV;
    $class->new(%opt);
}

sub run {
    my $self = shift;
    my $db = Cronin->db;
    my $name = $self->{name} // $self->command_to_name($self->{command}->[0]);
    my $host = $self->{host};
    my $user = $ENV{USER};
    my @command = @{$self->{command}};
    if (defined $host) {
        $user = $self->{user} if defined $self->{user};
        unshift @command, 'ssh', "$user\@$host";
    } else {
        $host = hostname;
    }
    my $task = $db->find_or_create_task($host, $name);
    my $cmd_str = join(' ', map { shell_quote_best_effort $_ } @{$self->{command}});
    my $log = $task->start({
        user    => $user,
        host    => $host,
        command => $cmd_str,
    });
    my $outbuf = '';
    my $errbuf = '';
    my $encoding = find_encoding($self->{encoding});
    die qq(encoding "$self->{encoding}" not found) unless ref $encoding;
    my $buffer_size = config->{buffer_size};
    my $cv = run_cmd \@command,
        '>' => sub {
            my $out = shift // return;
            print STDOUT $out if $self->{tee};
            $outbuf .= $encoding->decode($out);
            if (length $outbuf > $buffer_size) {
                $log->append_stdout($outbuf);
                $outbuf = '';
            }
        },
        '2>' => sub {
            my $err = shift // return;
            print STDERR $err if $self->{tee};
            $errbuf .= $encoding->decode($err);
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
        my $message = "cronin: command not found: $self->{command}\n";
        print STDERR $message if $self->{tee};
        $log->append_stderr($message);
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
    exists $self->{sns}    and $self->do_notify('SNS',    $task, $log, $self->{sns});
    exists $self->{http}   and $self->do_notify('HTTP',   $task, $log, $self->{http});
    exists $self->{email}  and $self->do_notify('Email',  $task, $log, $self->{email});
    exists $self->{stdout} and $self->do_notify('STDOUT', $task, $log, $self->{stdout});
}

sub do_notify {
    my ($self, $subclass, $task, $log, $destination) = @_;
    my $class = "Cronin::Notify::$subclass";
    load $class;
    my $notifier = $class->new(
        task => $task,
        log  => $log,
        json => $self->{json},
    );
    $notifier->notify($destination);
}

sub command_to_name {
    my ($self, $command) = @_;
    my $root = config->{project_root} or return $command;
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
