package Cronin::Config;
use strict;
use warnings;

use Exporter 'import';
use Scalar::Util qw(looks_like_number);

our @EXPORT = qw(config);

sub config {
    my $config = __PACKAGE__->load;
    no warnings 'redefine';
    *config = sub { $config };
    $config;
}

sub load {
    my ($class, @args) = @_;
    my $config;
    if (defined(my $file = $ENV{CRONIN_CONFIG_FILE})) {
        require Cronin::Config::File;
        $config = Cronin::Config::File->read($file);
    } else {
        require Cronin::Config::ENV;
        $config = Cronin::Config::ENV->read;
    }
    $class->init($config);
    $config;
}

sub init {
    my ($class, $config) = @_;
    $config->{base_url} or die "base_url is not set";
    if (defined(my $value = $config->{entries_per_page})) {
        die "entries_per_page: Not Positive Integer" if !looks_like_number($value) || $value < 1;
    } else {
        $config->{entries_per_page} = 50;
    }
    if (defined(my $value = $config->{buffer_size})) {
        die "buffer_size: Not Positive Integer" if !looks_like_number($value) || $value < 0;
        $config->{buffer_size} = $value;
    } else {
        $config->{buffer_size} = 0;
    }
    $config->{Email}->{to} //= $ENV{MAILTO}; # cron default
    $config->{HTTP}->{timeout} //= 30;
    $config->{STDOUT}->{encoding} //= 'UTF-8';
    1;
}

1;
__END__
