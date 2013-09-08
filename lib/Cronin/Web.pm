package Cronin::Web;
use Mojo::Base 'Mojolicious';

sub startup {
    my $self = shift;
    my $r = $self->routes;
    $r->get('/')->to('root#index');
    $r->get('/tasks/:task_id')->to('root#tasks');
    $r->get('/logs/:log_id')->to('root#logs');
    $r->get('/help')->to('root#help');
    $self->helper(truncate_str => sub {
        my ($self, $str, $len) = @_;
        return $str if length $str <= $len;
        substr($str, 0, $len) . "\x{2026}";
    });
#    require Mojo::Cache;
#    $self->hook(before_dispatch => sub { $self->renderer->cache(Mojo::Cache->new) });
}

1;
__END__
