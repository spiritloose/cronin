package Cronin::Notify::STDOUT;
use strict;
use warnings;
use parent 'Cronin::Notify';

sub notify {
    my $self = shift;
    print $self->build_message(pretty => 1, canonical => 1);
}

1;
__END__
