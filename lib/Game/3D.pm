
# This is just the version number and the documentation

package Game::3D;

# (C) by Tels <http://bloodgate.com/>

use strict;

use vars qw/$VERSION/;

$VERSION = '0.03';

1;

__END__

=pod

=head1 NAME

Game::3D - a package containing 3D points, vectors, areas, objects and links

=head1 SYNOPSIS

	use Game::3D::Point;

	my $origin = Game::3D::Point->new();

	my $point = Game::3D::Point->new ( x => 1, y => 0, z => -1);

=head1 EXPORTS

Exports nothing.

=head1 DESCRIPTION

This package is just the basis documentation for all the classes contained
under Game::3D. It does not need to be used, unless you want to require a
specific version of this package.

=head1 METHODS

This package defines no methods.

=head1 BUGS

None known yet.

=head1 AUTHORS

(c) 2003, Tels <http://bloodgate.com/>

=head1 SEE ALSO

L<SDL:App::FPS>, L<SDL::App> and L<SDL>.

L<GAME::3D::Point>.  L<GAME::3D::Area>.  L<GAME::3D::Vector>.
L<GAME::3D::Brush>.  L<GAME::3D::Level>.  L<GAME::3D::Link>.

=cut

