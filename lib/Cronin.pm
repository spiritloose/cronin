package Cronin;
use 5.10.1;
use strict;
use warnings;

our $VERSION = '0.01';

use Cronin::Config;
use Cronin::DB;

sub db {
    my $class = shift;
    my $config = config->{database};
    Cronin::DB->new(connect_info => [$config->{dsn}, $config->{user}, $config->{password}, {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
    }]);
}

1;
__END__
