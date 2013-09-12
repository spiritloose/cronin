package Cronin::DB::Row::Task;
use strict;
use warnings;
use parent 'Teng::Row';

use Cronin::Config;

sub start {
    my ($self, $data) = @_;
    my $txn = $self->handle->txn_scope;
    my $now = $self->handle->now;
    my $log = $self->handle->insert('logs' => {
        task_id    => $self->id,
        user       => $data->{user},
        host       => $data->{host},
        command    => $data->{command},
        stdout     => '',
        stderr     => '',
        started_at => $now,
        updated_at => $now,
    })->refetch;
    $self->update({
        last_executed_at => $now,
        last_log_id      => $log->id,
    });
    $txn->commit;
    $log;
}

sub write_pid {
    my ($self, $pid) = @_;
    $self->update({ pid => $pid });
}

sub finish {
    my $self = shift;
    $self->update({ pid => undef });
}

sub fetch_last_log {
    my $self = shift;
    $self->handle->find('logs' => $self->last_log_id);
}

sub logs {
    my ($self, $page) = @_;
    $page = 1 if $page =~ /\D/ or $page < 1;
    $self->handle->search_with_pager('logs' => { task_id => $self->id }, {
        order_by => 'started_at DESC',
        page     => $page,
        rows     => config->{entries_per_page},
    });
}

1;
__END__
