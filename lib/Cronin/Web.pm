package Cronin::Web;
use Mojo::Base 'Mojolicious';
use Cronin::Config ();

sub startup {
    my $self = shift;
    Cronin::Config::config(); # to load config
    my $r = $self->routes;
    $r->get('/')->name('index')->to('root#index');
    $r->get('/tasks/:task_id')->name('tasks')->to('root#tasks');
    $r->get('/hosts/:host')->name('hosts')->to('root#hosts');
    $r->get('/logs/:log_id')->name('logs')->to('root#logs');
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
