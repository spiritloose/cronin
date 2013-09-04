package Cronin;
use 5.10.1;
use strict;
use warnings;

our $VERSION = '0.01';

my $Config = {
    project_root     => $ENV{CRONIN_PROJECT_ROOT} // '',
    entries_per_page => $ENV{CRONIN_ENTRIES_PER_PAGE} // 50,
    base_url         => $ENV{CRONIN_BASE_URL} // 'http://cronin.example.com/',
    buffer_size      => $ENV{CRONIN_BUFFER_SIZE} // 0,
};

sub config { $Config }

our $DBD_UTF8_OPTIONS = {
    mysql  => 'mysql_enable_utf8',
    SQLite => 'sqlite_unicode',
    Pg     => 'pg_enable_utf8',
};

sub db {
    require DBI;
    require Cronin::DB;
    my $dsn = $ENV{CRONIN_DB_DSN} or die "CRONIN_DB_DSN is not set";
    my $user = $ENV{CRONIN_DB_USER} || '';
    my $password = $ENV{CRONIN_DB_PASSWORD} || '';
    my @dsn = DBI->parse_dsn($dsn);
    my $driver = $dsn[1];
    Cronin::DB->new(connect_info => [$dsn, $user, $password, {
        RaiseError => 1,
        PrintError => 0,
        AutoCommit => 1,
        $DBD_UTF8_OPTIONS->{$driver} ? ($DBD_UTF8_OPTIONS->{$driver} => 1) : (),
    }]);
}

1;
__END__
