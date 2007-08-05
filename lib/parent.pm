package parent;
use strict;
use vars qw($VERSION);
$VERSION = '0.216';

sub SUCCESS() { 1 };

sub import {
    my $class = shift;

    return SUCCESS unless @_;

    my $inheritor = caller(0);

    # build list of pairs ( class => module, ...)
    my @bases = map ref() eq 'ARRAY' ? @$_ : ( $_ => $_), @_;

    my @bases2;
    while ( my ( $base, $module) = splice @bases, 0, 2 ) {
        if ( $inheritor eq $base ) {
            warn "Class '$inheritor' tried to inherit from itself\n";
        }

	push @bases2, $base;

        next unless defined $module;

        my $filename = $module;
	if ($filename !~ m{/}) { # the module does not look like a filename?
            # create a filename from the class name
	    $filename =~ s{::|'}{/}g;
            $filename .= '.pm';
	};
        require $filename; # dies if the file is not found
    }
    {
        no strict 'refs';
	# This is more efficient than push for the new MRO
        @{"$inheritor\::ISA"} = (@{"$inheritor\::ISA"} , @bases2);
    };
};

"All your base are belong to us"

__END__

=head1 NAME

parent - Establish an ISA relationship with base classes at compile time

=head1 WARNING

This is a B<beta release>. While the "normal" interface for simple
inheritance will stay fixed, the interface for loading a class from
a different class or different file is still in flux as the
best API has not yet been determined.

=head1 SYNOPSIS

    package Baz;
    use parent qw(Foo Bar);

=head1 DESCRIPTION

Allows you to both load one or more modules, while setting up inheritance from
those modules at the same time.  Mostly similar in effect to

    package Baz;
    BEGIN {
        require Foo;
        require Bar;
        push @ISA, qw(Foo Bar);
    }

By default, every base class needs to live in a file of its own.
If you want to subclass a package that lives in a differently
named module, you can use the following syntax to inherit from it:

  package MyHash;
  use parent [ 'Tie::StdHash' => 'Tie::Hash' ];

This is equivalent to the following code:

  package MyHash;
  require Tie::Hash;
  push @ISA, 'Tie::StdHash';

If you want to have a subclass and its parent class in the same file, you
can tell C<parent> not to load a class in the following way:

  package Foo;
  sub exclaim { "I CAN HAS PERL" }

  package DoesNotLoadFoo;
  use parent [ Foo => undef ]; # will not go looking for Foo.pm

This is equivalent to the following code:

  package Foo;
  sub exclaim { "I CAN HAS PERL" }

  package DoesNotLoadFoo;
  push @DoesNotLoadFoo::ISA, 'Foo';

The base class' C<import> method is B<not> called.

If you want to load a subclass from a file that C<require> would
not consider an eligible filename (that is, it does not end in
either C<.pm> or C<.pmc>), you can specify the filename,
as long as it contains at least one C</>:

  package MySecondPlugin;
  use parent [ 'Plugin::Custom' => './plugins/custom.plugin' ];

This is equivalent to the following code:

  package MySecondPlugin;
  require './plugins/custom.plugin';
  push @ISA, 'Plugin::Custom';

The determination of whether something is a class name or a filename
is solely based on whether the second array entry contains
at least one C</>. This precludes you from using
class names that contain a forward slash with this package.

=head1 DIAGNOSTICS

=over 4

=item Class 'Foo' tried to inherit from itself

Attempting to inherit from yourself generates a warning.

    use Foo;
    use parent 'Foo';

=back

=head1 HISTORY

This module was forked from L<base> to remove the cruft
that had accumulated in it.

=head1 CAVEATS

=head1 SEE ALSO

L<base>

=head1 AUTHORS AND CONTRIBUTORS

Rafaël Garcia-Suarez, Bart Lateur, Max Maischein, Anno Siegel, Michael Schwern

=head1 MAINTAINER

Max Maischein C< corion@cpan.org >

=cut
