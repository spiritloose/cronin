requires 'perl', '5.10.1';
requires 'Mojolicious';
requires 'Plack';
requires 'Teng';
requires 'AnyEvent';
requires 'Time::Piece', '> 1.15';
requires 'String::ShellQuote';

feature 'sns', 'Notify::SNS' sub {
    recommends 'Amazon::SNS';
};

feature 'http', 'Notify::HTTP' sub {
    recommends 'LWP::UserAgent';
};

feature 'email', 'Notify::Email' sub {
    recommends 'Email::MIME';
    recommends 'Email::Sender';
};
