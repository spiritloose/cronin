package Cronin::Config::File;
use strict;
use warnings;

use JSON ();

sub read {
    my ($class, $file) = @_;
    open my $fh, '<', $file or die $!;
    my $content = do { local $/; <$fh> };
    JSON->new->relaxed(1)->decode($content);
}

1;
__END__
