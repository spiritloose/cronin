package Cronin::Notify::Email;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin;
use Encode;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

sub notify {
    my $self = shift;
    my $to = $self->target || $ENV{MAILTO} or die 'MAILTO is not set';
    my $from = $ENV{CRONIN_NOTIFY_EMAIL_FROM} || $to;
    my $subject = sprintf 'Cronin - %s', $self->task->name;
    my $email = Email::MIME->create(
        header => [
            To                 => $to,
            From               => $from,
            Subject            => encode('MIME-Header', $subject),
            'X-Cronin-Task'    => encode('MIME-Header', $self->task->name),
            'X-Cronin-Version' => encode('MIME-Header', $Cronin::VERSION),
        ],
        body => $self->text_message,
        attributes => {
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => '8bit'
        },
    );
    sendmail $email;
}

1;
__END__
