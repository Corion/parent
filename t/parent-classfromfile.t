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

# Tests that a bare (non-double-colon) class still loads
# and does not get treated as a file:
eval sprintf q{package Test2; require '%s/lib/Dummy2.plugin'; use parent -norequire, 'Dummy2::InlineChild' }, $base;
is $@, '', "Loading a class from a file works";
isn't $INC{"$base/lib/Dummy2.plugin"}, undef, "We loaded the plugin file";
my $o = bless {}, 'Test2';
isa_ok $o, 'Dummy2::InlineChild';
