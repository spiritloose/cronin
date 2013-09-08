requires 'perl', '5.10.1';
requires 'Mojolicious';
requires 'Teng';
requires 'AnyEvent';
requires 'JSON', '2';
requires 'Time::Piece', '> 1.15';
requires 'String::ShellQuote';

feature 'sqlite', 'DBD::SQLite', sub {
    requires 'DBD::SQLite';
};

feature 'mysql', 'DBD::mysql', sub {
    requires 'DBD::mysql';
};

feature 'sns', 'Notify::SNS', sub {
    requires 'Amazon::SNS';
};

feature 'http', 'Notify::HTTP', sub {
    requires 'LWP::UserAgent';
};

feature 'email', 'Notify::Email', sub {
    requires 'Email::MIME';
    requires 'Email::Sender';
};

feature 'email-smtp-tls', 'Notify::Email::SMTP::TLS', sub {
    requires 'Email::Sender::Transport::SMTP::TLS';
};
