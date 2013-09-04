package Cronin::Notify::Email;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin;
use List::Util qw(first);
use Encode;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

our $ENCODING_MAP = {
    ascii => {
        header   => 'MIME-Header',
        charset  => 'US-ASCII',
        encoding => '7bit',
    },
    utf8 => {
        header   => 'MIME-Header',
        charset  => 'UTF-8',
        encoding => '8bit',
    },
    iso_2022_jp => {
        header   => 'MIME-Header-ISO_2022_JP',
        charset  => 'ISO-2022-JP',
        encoding => '7bit',
    },
};

sub notify {
    my $self = shift;
    my $to = $self->target || $ENV{MAILTO} or die 'MAILTO is not set';
    my $from = $ENV{CRONIN_NOTIFY_EMAIL_FROM} || $to;
    my $subject = sprintf 'Cronin - %s', $self->task->name;
    my $body = $self->text_message_utf8;
    my $encoding = $ENCODING_MAP->{ascii};
    if ($ENV{CRONIN_NOTIFY_EMAIL_ISO_2022_JP}) {
        $encoding = $ENCODING_MAP->{iso_2022_jp};
    } elsif (first { /[^[:ascii:]]/ } ($to, $from, $subject, $body)) {
        $encoding = $ENCODING_MAP->{utf8};
    }
    my $email = Email::MIME->create(
        header => [
            To                 => $to,
            From               => $from,
            Subject            => encode($encoding->{header}, $subject),
            'X-Cronin-Task'    => encode($encoding->{header}, $self->task->name),
            'X-Cronin-Version' => encode($encoding->{header}, $Cronin::VERSION),
        ],
        body => encode($encoding->{charset}, $body),
        attributes => {
            content_type => 'text/plain',
            charset      => $encoding->{charset},
            encoding     => $encoding->{encoding},
        },
    );
    sendmail $email;
}

1;
__END__
