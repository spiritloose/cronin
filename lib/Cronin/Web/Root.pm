package Cronin::Web::Root;
use Mojo::Base 'Mojolicious::Controller';
use Cronin;

sub index {
    my $self = shift;
    my $page = $self->req->param('page') || 1;
    my ($tasks, $pager) = Cronin->db->get_tasks($page);
    $self->render(tasks => $tasks, pager => $pager);
}

sub tasks {
    my $self = shift;
    my $id = $self->stash('task_id');
    my $task = Cronin->db->find('tasks', $id); # TODO: handle not found
    my $page = $self->req->param('page') || 1;
    my ($logs, $pager) = $task->logs($page);
    $self->render(task => $task, logs => $logs, pager => $pager);
}

sub logs {
    my $self = shift;
    my $id = $self->stash('log_id');
    my $log = Cronin->db->find('logs', $id); # TODO: handle not found
    my $task = $log->fetch_task;
    $self->render(log => $log, task => $task);
}

sub help {
    my $self = shift;
    $self->render;
}

1;
__END__
