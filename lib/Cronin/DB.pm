package Cronin::DB;
use strict;
use warnings;
use parent 'Teng';

use Cronin::Config;
use Time::Piece;

__PACKAGE__->load_plugin('Pager');

sub find {
    my ($self, $table, $id) = @_;
    $self->single($table, { id => $id });
}

sub find_or_create_task {
    my ($self, $name) = @_;
    my $row = $self->single('tasks' => { name => $name });
    return $row if $row;
    my $now = $self->now;
    $self->insert('tasks' => {
        name       => $name,
        created_at => $now,
        updated_at => $now,
    })->refetch;
}

sub now { Time::Piece->new }

sub get_tasks {
    my ($self, $page) = @_;
    $page = 1 if $page =~ /\D/ or $page < 1;
    $self->search_with_pager('tasks' => {}, {
        order_by => 'last_executed_at DESC, pid IS NOT NULL',
        page     => $page,
        rows     => config->{entries_per_page},
    });
}

1;
__END__
