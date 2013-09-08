package Cronin::Notify::Email;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin::Config;
use Encode;
use Email::MIME;
use Email::Sender::Simple qw(sendmail);

sub notify {
    my ($self, $to) = @_;
    $to ||= config->{Email}->{to} or die 'Email: to is not set';
    my $from = config->{Email}->{from} // $to;
    my $subject = sprintf 'Cronin - %s', $self->task->name;
    my $body = $self->build_message(pretty => 1, canonical => 1);
    my $encoding = $body =~ /[^[:ascii:]]/ ? 'quoted-printable' : '7bit';
    my $email = Email::MIME->create(
        header => [
            To                 => $to,
            From               => $from,
            Subject            => encode('MIME-Header', $subject),
            'X-Cronin-Task'    => encode('MIME-Header', $self->task->name),
            'X-Cronin-Version' => encode('MIME-Header', $Cronin::VERSION),
        ],
        body => encode_utf8($body),
        attributes => {
            content_type => 'text/plain',
            charset      => 'UTF-8',
            encoding     => $encoding,
        },
    );
    my $args = $self->sendmail_args;
    sendmail $email, $args;
}

sub sendmail_args {
    my $self = shift;
    if (config->{Email}->{smtp_tls}) {
        require Email::Sender::Transport::SMTP::TLS;
        my $config = config->{Email}->{tls};
        for my $key (keys %$config) {
            delete $config->{$key} unless defined $config->{$key};
        }
        my $transport = Email::Sender::Transport::SMTP::TLS->new(%$config);
        +{ transport => $transport };
    } else {
        +{};
    }
}

1;
__END__
