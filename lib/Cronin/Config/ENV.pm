package Cronin::Config::ENV;
use strict;
use warnings;

sub read {
    my $class = shift;
    +{
        project_root     => $ENV{CRONIN_PROJECT_ROOT} // undef,
        base_url         => $ENV{CRONIN_BASE_URL} // undef,
        entries_per_page => $ENV{CRONIN_ENTRIES_PER_PAGE} // undef,
        buffer_size      => $ENV{CRONIN_BUFFER_SIZE} // undef,
        database => {
            dsn      => $ENV{CRONIN_DB_DSN} // undef,
            user     => $ENV{CRONIN_DB_USER} // undef,
            password => $ENV{CRONIN_DB_PASSWORD} // undef,
        },
        SNS => {
            arn     => $ENV{CRONIN_NOTIFY_SNS_ARN} // undef,
            use_cli => $ENV{CRONIN_NOTIFY_SNS_USE_CLI} // undef,
        },
        HTTP => {
            url     => $ENV{CRONIN_NOTIFY_HTTP_URL} // undef,
            timeout => $ENV{CRONIN_NOTIFY_HTTP_TIMEOUT} // undef,
        },
        Email => {
            to          => $ENV{CRONIN_NOTIFY_EMAIL_TO} // undef,
            from        => $ENV{CRONIN_NOTIFY_EMAIL_FROM} // undef , # 'to' is used if undef
            smtp_tls    => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS} // undef,
            tls => {
                host                  => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_HOST} // undef,
                port                  => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_PORT} // undef,
                username              => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_USERNAME} // undef,
                password              => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_PASSWORD} // undef,
                helo                  => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_USERNAME} // undef,
                allow_partial_success => $ENV{CRONIN_NOTIFY_EMAIL_SMTP_TLS_ALLOW_PARTIAL_SUCCESS} // undef,
            },
        },
        STDOUT => {
            encoding => $ENV{CRONIN_NOTIFY_STDOUT_ENCODING} // undef,
        },
    };
}

1;
__END__
