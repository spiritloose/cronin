package Cronin::DB::Schema;
use strict;
use warnings;

use Teng::Schema::Declare;
use Time::Piece;

sub inflate_datetime {
    inflate qr/.+_at$/ => sub {
        my $val = shift // return;
        localtime Time::Piece->strptime($val, '%Y-%m-%d %H:%M:%S');
    };
    deflate qr/.+_at$/ => sub {
        my $val = shift // return;
        $val->strftime('%Y-%m-%d %H:%M:%S');
    };
}

table {
    name 'tasks';
    row_class 'Cronin::DB::Row::Task';
    pk 'id';
    columns qw(id host name pid last_executed_at last_log_id created_at updated_at);
    inflate_datetime;
};

table {
    name 'logs';
    row_class 'Cronin::DB::Row::Log';
    pk 'id';
    columns qw(id task_id pid user host command exit_code stdout stderr started_at updated_at finished_at);
    inflate_datetime;
};

1;
__END__
