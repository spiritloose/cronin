requires 'perl', '5.10.1';
requires 'Mojolicious';
requires 'Teng';
requires 'AnyEvent';
requires 'Time::Piece', '> 1.15';
requires 'String::ShellQuote';

feature 'sqlite', 'DBD::SQLite', sub {
    recommends 'DBD::SQLite';
};

feature 'mysql', 'DBD::mysql', sub {
    recommends 'DBD::mysql';
};

feature 'sns', 'Notify::SNS', sub {
    recommends 'Amazon::SNS';
};

feature 'http', 'Notify::HTTP', sub {
    recommends 'LWP::UserAgent';
};

feature 'email', 'Notify::Email', sub {
    recommends 'Email::MIME';
    recommends 'Email::Sender';
};

feature 'email-smtp-tls', 'Notify::Email::SMTP::TLS', sub {
    recommends 'Email::Sender::Transport::SMTP::TLS';
};
