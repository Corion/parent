#!/usr/bin/perl -w
BEGIN {
    if( $ENV{PERL_CORE} ) {
        chdir 't' if -d 't';
        chdir '../lib/parent';
        @INC = '..';
    }
}

use strict;
use Test::More;
use Config;
use lib 't/lib';

plan skip_all => ".pmc are only available with 5.6 and later" if $] < 5.006;

# Skip this test if perl is compiled with PERL_DISABLE_PMC
#
if (Config->can('non_bincompat_options')) { # $] ge '5.014')
    # We can use non_bincompat_options
    plan skip_all => 'Perl is built with PERL_DISABLE_PMC'
        if grep { $_ eq 'PERL_DISABLE_PMC' } Config::non_bincompat_options();
} else {
    # Fallback to Config::Perl::V (optional test dependency)
    plan skip_all => 'Config::Perl::V is not installed'
        unless eval { require 'Config/Perl/V.pm'; 1 };
    Config::Perl::V->VERSION('0.10');
    plan skip_all => 'Perl is built with PERL_DISABLE_PMC'
        if Config::Perl::V::myconfig()->{options}{PERL_DISABLE_PMC};
}

plan tests => 3;

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
