requires 'perl', '5.10.1';
requires 'Mojolicious';
requires 'Teng';
requires 'AnyEvent';
requires 'JSON', 2;
requires 'Time::Piece', '> 1.15';
requires 'String::ShellQuote';

feature 'sqlite', 'SQLite support', sub {
    requires 'DBD::SQLite';
};

feature 'mysql', 'MySQL support', sub {
    requires 'DBD::mysql';
};

feature 'sns', 'Amazon SNS support', sub {
    requires 'Amazon::SNS';
};

feature 'http', 'HTTP support', sub {
    requires 'LWP', 6;
};

feature 'https', 'https support', sub {
    requires 'LWP::Protocol::https';
};

feature 'email', 'Email support', sub {
    requires 'Email::MIME';
    requires 'Email::Sender';
};

feature 'email-smtp-tls', 'SMTP TLS support', sub {
    requires 'Email::Sender::Transport::SMTP::TLS';
};
