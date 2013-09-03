package Cronin::Notify;
use strict;
use warnings;

use Class::Accessor::Lite new => 1, ro => [qw(task log target json)];
use JSON ();
use Encode ();
use Mojo::Template;

sub build_message {
    my ($self, %properties) = @_;
    $self->json ? $self->json_message(%properties) : $self->text_message;
}

sub json_message {
    my ($self, %properties) = @_;
    my $json = JSON->new;
    for my $property (keys %properties) {
        $json->property($property => $properties{$property});
    }
    my $data = $self->log->get_columns;
    $data->{url} = $self->log->url;
    $data->{task_name} = $self->task->name;
    Encode::encode_utf8($json->encode($data));
}

our $TEXT_TEMPLATE = <<'END_TEMPLATE';
% my ($task, $log) = @_;
URL: <%== $log->url %>
Task: <%== $task->name %>
Start: <%== $log->started_at->strftime('%Y-%m-%d %H:%M:%S') %>
End: <%== $log->started_at->strftime('%Y-%m-%d %H:%M:%S') %>
Time: <%== $log->finished_at - $log->started_at %> sec
Exit code: <%== $log->exit_code %>
ARGV: <%== $log->argv%>
STDOUT: <%== $log->stdout %>
STDERR: <%== $log->stderr %>
User: <%== $log->user %>
Hostname: <%== $log->hostname %>
PID: <%== $log->pid %>
END_TEMPLATE

sub text_message {
    my $self = shift;
    my $mt = Mojo::Template->new;
    Encode::encode_utf8($mt->render($TEXT_TEMPLATE, $self->task, $self->log));
}

1;
__END__
