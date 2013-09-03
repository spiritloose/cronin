package Cronin::Notify::SNS;
use strict;
use warnings;
use parent 'Cronin::Notify';

sub notify {
    my $self = shift;
    my $arn = $self->target || $ENV{CRONIN_NOTIFY_SNS_ARN} or die "CRONIN_NOTIFY_SNS_ARN is not set";
    my $message = $self->build_message(pretty => 1, canonical => 1);
    if (eval { require Amazon::SNS; 1 }) {
        $self->send_via_amazon_sns($arn, $message);
    } else {
        $self->send_via_sns_publish($arn, $message);
    }
}

sub send_via_sns_publish {
    my ($self, $arn, $message) = @_;
    system 'sns-publish', $arn, '--message', $message and die $!;
}

sub send_via_amazon_sns {
    my ($self, $arn, $message) = @_;
    my $service = $ENV{AWS_SNS_URL};
    unless ($service) {
        my $region = $ENV{AWS_REGION} || 'us-east-1';
        $service = "https://sns.$region.amazonaws.com/";
    }
    my $sns = Amazon::SNS->new({
        key     => ($ENV{AWS_ACCESS_KEY_ID}     || die "AWS_ACCESS_KEY_ID is not set"),
        secret  => ($ENV{AWS_SECRET_ACCESS_KEY} || die "AWS_SECRET_ACCESS_KEY is not set"),
        service => $service,
    });
    my $topic = $sns->GetTopic($arn);
    $topic->Publish($message);
}

1;
__END__
