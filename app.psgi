#!/usr/bin/env plackup
use strict;
use warnings;

use Cronin::Web;
use Plack::Builder;
use Mojo::Server::PSGI;

my $psgi = Mojo::Server::PSGI->new(app => Cronin::Web->new);

builder {
    enable 'Static', path => qr{^/(css|img|js)/}, root => './public/';
    $psgi->to_psgi_app;
};
