
# Physical - a base class for 3D physical objects (e.g. with mass)

package Game::3D::Physical;

# (C) by Tels <http://bloodgate.com/>

use strict;

require Exporter;
use Game::3D::Area;
use Game::3D::Thingy;
use vars qw/@ISA $VERSION/;

@ISA = qw/Game::3D::Thingy Game::3D::Area Exporter/;

$VERSION = '0.01';

##############################################################################
# methods

sub _init
  {
  # to be overwritten in subclasses
  my $self = shift;

  my $args = $_[0];
  $args = { @_ } unless ref $args eq 'HASH';

  Game::3D::Area::_init($self,$args);

  $self->new_attr(
	-name => "mass",
	-type => 'number',
	-value => $args->{mass} || 100,
	-minimum => 0,
  );
#  $self->{mass} = abs($args->{mass} || 100);

  $self;
  }

#sub mass
#  {
#  # return mass
#  my $self = shift;
#  $self->{mass} = shift if defined $_[0];
#  $self->{mass};
#  }

1;

__END__

=pod

=head1 NAME

Game::3D::Physical - an 3D object with mass

=head1 SYNOPSIS

	use Game::3D::Physical;

	my $object = Game::3D::Physical->new( mass => 45 );
	$object->mass(123);

=head1 EXPORTS

Exports nothing on default.

=head1 DESCRIPTION

This package provides a base class for shapes/areas in 3D space.

=head1 METHODS

It features all the methods of Game::3D::Area (namely: new(), _init(),
x(), y(), z(), width(), length(), height(), size() and center()) plus:

=over 2

=item mass()

	print $object->mass();
	$object->mass(123);
	
Set and return or just return the object's mass (in simple units).

=back

=head1 AUTHORS

(c) 2003, Tels <http://bloodgate.com/>

=head1 SEE ALSO

L<Game::3D::Area>, L<Game::3D::Thingy> as well as
L<SDL:App::FPS>, L<SDL::App> and L<SDL>.

=cut

