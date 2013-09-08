package Cronin::Notify::SNS;
use strict;
use warnings;
use parent 'Cronin::Notify';

use Cronin::Config;
use Encode;
use JSON;
use AnyEvent::Util qw(run_cmd);

sub notify {
    my ($self, $arn) = @_;
    $arn ||= config->{SNS}->{arn} or die "SNS: arn is not set";
    my $message = $self->build_message(pretty => 1, canonical => 1);
    if (config->{SNS}->{use_cli}) {
        $self->send_via_cli($arn, $message);
    } else {
        $self->send_via_amazon_sns($arn, $message);
    }
}

sub send_via_cli {
    my ($self, $arn, $message) = @_;
    my @cmd = (qw[aws sns publish],
        '--topic-arn' => $arn,
        '--message'   => encode_utf8($message),
    );
    my $cv = run_cmd \@cmd,
        '>'  => \my $stdout,
        '2>' => \my $stderr,
        'close_all' => 1;
    my $exit_code = $cv->recv;
    $exit_code >>= 8;
    if ($exit_code == 126 && length $stderr == 0) { # exec failed
        die "cronin: command not found: aws";
    }
    if ($stdout) {
        my $res = decode_json($stdout);
        $res->{MessageId} and return;
    }
    die $stderr || "SNS: `aws sns publish` failed!";
}

sub send_via_amazon_sns {
    my ($self, $arn, $message) = @_;
    require Amazon::SNS;
    my $service = $ENV{AWS_SNS_URL};
    unless (defined $service) {
        my $region = $ENV{AWS_DEFAULT_REGION} || 'us-east-1';
        $service = "https://sns.$region.amazonaws.com/";
    }
    my $sns = Amazon::SNS->new({
        key     => ($ENV{AWS_ACCESS_KEY_ID}     || die "AWS_ACCESS_KEY_ID is not set"),
        secret  => ($ENV{AWS_SECRET_ACCESS_KEY} || die "AWS_SECRET_ACCESS_KEY is not set"),
        service => $service,
    });
    my $topic = $sns->GetTopic($arn);
    $topic->Publish($message) or die $sns->error;
}

1;
__END__
