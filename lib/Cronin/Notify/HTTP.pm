package Cronin::Notify::HTTP;
use strict;
use warnings;
use parent 'Cronin::Notify';

use LWP::UserAgent;

sub notify {
    my $self = shift;
    my $url = $self->target || $ENV{CRONIN_NOTIFY_HTTP_URL} or die "CRONIN_NOTIFY_HTTP_URL is not set";
    my $ua = LWP::UserAgent->new(agent => "Cronin/$Cronin::VERSION");
    my $payload = $self->json_message;
    my $res = $ua->post($url, { payload => $payload });
    die $res->status_line if $res->is_error;
}

1;
__END__
