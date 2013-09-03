package Cronin;
use strict;
use warnings;

our $VERSION = '0.01';

my $Config = {
    ProjectRoot => $ENV{CRONIN_PROJECT_ROOT} // '',
    DBI => ['dbi:SQLite:dbname=/tmp/cronin.db', '', '', {
        RaiseError     => 1,
        PrintError     => 0,
        AutoCommit     => 1,
        sqlite_unicode => 1,
    }],
    'Pager'   => { rows => 50 },
    'SNS'     => $ENV{CRONIN_SNS_ARN} // '',
    'BaseURL' => 'https://cronin.example.com/',
};

sub config { $Config }

sub db {
    require Cronin::DB;
    Cronin::DB->new(connect_info => $Config->{DBI});
}

1;
__END__
