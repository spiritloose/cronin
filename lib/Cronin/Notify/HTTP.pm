package Cronin::Notify::HTTP;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin::Config;
use Encode;
use LWP::UserAgent;

sub notify {
    my ($self, $url) = @_;
    $url ||= config->{HTTP}->{url} or die "HTTP: url is not set";
    my $ua = LWP::UserAgent->new(
        agent     => "Cronin/$Cronin::VERSION",
        timeout   => config->{HTTP}->{timeout},
        env_proxy => 1,
    );
    my $payload = encode_utf8($self->json_message);
    my $res = $ua->post($url, { payload => $payload });
    die $res->status_line if $res->is_error;
}

1;
__END__
