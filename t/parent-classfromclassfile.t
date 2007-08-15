#!/usr/bin/perl -w

BEGIN {
   if( $ENV{PERL_CORE} ) {
        chdir 't' if -d 't';
        @INC = qw(../lib lib);
    } else {
        push @INC, 't/lib';
    };
}

use strict;
use Test::More tests => 3;

use_ok('parent');

# Tests that a bare (non-double-colon) class still loads
# and does not get treated as a file:
eval q{package Test1; require Dummy; use parent -norequire, 'Dummy::InlineChild'; };
is $@, '', "Loading an unadorned class works";
isn't $INC{"Dummy.pm"}, undef, 'We loaded Dummy.pm';
