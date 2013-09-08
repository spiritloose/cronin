#!/usr/bin/env plackup
use strict;
use warnings;

use Cronin::Config;
use Cronin::Web;
use Plack::Builder;
use Mojo::Server::PSGI;

my $psgi = Mojo::Server::PSGI->new(app => Cronin::Web->new);
Cronin::Config->load; # in parent process

builder {
    enable 'Static', path => qr{^/(css|img|js)/}, root => './public/';
    $psgi->to_psgi_app;
};
