package Cronin::Notify::STDOUT;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin::Config;
use Encode;

sub notify {
    my $self = shift;
    my $content = $self->build_message(pretty => 1, canonical => 1);
    print encode(config->{STDOUT}->{encoding}, $content);
}

1;
__END__
