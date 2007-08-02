#!/usr/bin/perl -w
use strict;
use Test::More tests => 3;
use lib 't/lib';

use vars qw($got_here);

my $res = eval q{
    package MyTest;

    use parent 'FileThatOnlyExistsAsPMC';

    1
};
my $error = $@;

is $res, 1, "Block ran until the end";
is $error, '', "No error";

my $obj = bless {}, 'FileThatOnlyExistsAsPMC';
can_ok $obj, 'exclaim';
