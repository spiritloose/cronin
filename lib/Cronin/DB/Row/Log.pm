package Cronin::DB::Row::Log;
use strict;
use warnings;
use parent 'Teng::Row';

use Cronin::Config;

sub time {
    my $self = shift;
    my $time = $self->finished_at || $self->handle->now;
    $time - $self->started_at;
}

sub fetch_task {
    my $self = shift;
    $self->handle->find('tasks', $self->task_id);
}

sub write_pid {
    my ($self, $pid) = @_;
    $self->update({ pid => $pid });
}

sub finish {
    my ($self, $exit_code) = @_;
    $self->update({
        exit_code   => $exit_code,
        finished_at => $self->handle->now,
    });
}

sub append_stdout {
    my ($self, $out) = @_;
    if ($self->handle->dbh->{Driver}->{Name} eq 'mysql') {
        $self->update({ stdout => \['CONCAT(stdout, ?)', $out] });
    } else {
        $self->update({ stdout => \['stdout || ?', $out] });
    }
}

sub append_stderr {
    my ($self, $err) = @_;
    if ($self->handle->dbh->{Driver}->{Name} eq 'mysql') {
        $self->update({ stderr => \['CONCAT(stderr, ?)', $err] });
    } else {
        $self->update({ stderr => \['stderr || ?', $err] });
    }
}

sub url {
    my $self = shift;
    config->{base_url} . 'logs/' . $self->id;
}

1;
__END__
