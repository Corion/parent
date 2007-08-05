#!/usr/bin/perl -w

my $base;
BEGIN {
   if( $ENV{PERL_CORE} ) {
        chdir 't' if -d 't';
        @INC = qw(../lib lib);
	$base = '.';
    } else {
        push @INC, 't/lib';
	$base = './t';
    };
}

use strict;
use Test::More tests => 4;

use_ok('parent');

# Tests that a weirdo class name containing dots still loads
# and does not get treated as a file:
eval q{package Test1; use parent [ 'Dummy::InlineChild' => 'Dummy.pm' ] };
like $@, q{/Dummy\.pm\.pm/}, "Loading an unadorned class fails in the expected way";

# Tests that a bare (non-double-colon) class still loads
# and does not get treated as a file:
eval sprintf q{package Test2; use parent [ 'Dummy2::InlineChild' => '%s/lib/Dummy2.plugin' ] }, $base;
is $@, '', "Loading a class from a file works";
isn't $INC{"$base/lib/Dummy2.plugin"}, undef, "We loaded the plugin file";
