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
    my $task = Cronin->db->find('tasks', $id) or return $self->render_not_found;
    my $page = $self->req->param('page') || 1;
    my ($logs, $pager) = $task->logs($page);
    $self->render(task => $task, logs => $logs, pager => $pager);
}

sub hosts {
    my $self = shift;
    my $host = $self->stash('host');
    my $page = $self->req->param('page') || 1;
    my ($logs, $pager) = Cronin->db->get_host_logs($host, $page);
    $self->render(host => $host, logs => $logs, pager => $pager);
}

sub logs {
    my $self = shift;
    my $id = $self->stash('log_id');
    my $log = Cronin->db->find('logs', $id) or return $self->render_not_found;
    my $task = $log->fetch_task or return $self->render_not_found;
    $self->render(log => $log, task => $task);
}

1;
__END__
