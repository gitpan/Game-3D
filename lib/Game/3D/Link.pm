
# Link - link two objects together and allow sending a signal(s) between them

package Game::3D::Link;

# (C) by Tels <http://bloodgate.com/>

use strict;

require Exporter;
use Game::3D::Signal qw/SIGNAL_FLIP SIGNAL_OFF/;
use Game::3D::Thingy;
use vars qw/@ISA $VERSION/;
@ISA = qw/Exporter Game::3D::Thingy/;

$VERSION = '0.01';

##############################################################################
# protected class vars

{
  sub add_timer { die ("You need to set a timer callback first.") };
  my $timer = 'Game::3D::Link';		# make it point to our add_timer()
  sub timer_provider
    {
    $timer = shift if @_ > 0;
    $timer;
    }
}

##############################################################################
# methods

sub _init
  {
  my $self = shift;

  $self->{inputs} = {};  
  $self->{count} = 1;				# send signal only once  
  $self->{delay} = 0;				# immidiately
  $self->{resend} = 2000;			# 2 seconds if count != 1
  $self->{rand} = 0;				# exactly
  $self->{once} = 0;				# not once
  $self->{fixed_output} = undef;		# none
  $self->{invert} = 0;				# not
  $self;
  }

# override signal() to be more complex than Thingy's default

sub signal
  {
  my ($self,$input,$sig) = @_;

  my $in = $self->{inputs};
  die ("Unregistered input $input tried to send signal to link $self->{id}")
   if !exists $in->{$input};
  if ($sig == SIGNAL_FLIP)
    {
    $in->{$input} = - $in->{$input};		# invert()
    }
  else
    {
    $in->{$input} = $sig;
    }
  return unless $self->{active} == 1;	# inactive links don't send signals

  # all inputs must be in the same state to send the signal
  my $state = $in->{$input};
  foreach my $i (keys %$in)
    {
    return if ($in->{$i} != $state);
    }

  # if we need to always send the same signal, do so
  if (defined $self->{fixed_output})
    {
    $sig = $self->{fixed_output};
    }
  elsif ($self->{invert})
    {
    $sig = -$sig;				# invert()
    }
  
  # need to delay sending, or send more than one time
  if ($self->{count} != 1 || $self->{delay} != 0)
    {
    timer()->add_timer(
      $self->{delay}, $self->{count}, $self->{resend}, $self->{rand},
      sub 
        {
        $self->output($input,$sig);
        },
     );
    }
  else
    {
    # Send signal straight away. 
    $self->output($input,$sig);		# $signal from $input
    }
  $self->deactivate() if $self->{once};
  }

sub link
  {
  my ($self,$src,$dst) = @_;

  $self->{inputs}->{$src->{id}} = SIGNAL_OFF;
  $self->{outputs}->{$dst->{id}} = $dst;
  $src->add_output($self);			# the link appears as output
  $dst->add_input($self);			# and input at both ends
  }

# override input() to add the input
sub add_input
  {
  my ($self,$src) = @_;

  $self->{inputs}->{$src->{id}} = SIGNAL_OFF;
  }

sub delay
  {
  # Sets the initial delay of the link, the delay for each consecutive signal,
  # and athe randomized offset for these times.
  # Note that the second delay only comes into play if the
  # count() was set to a value different than 1, otherwise each firing of the
  # link will use the first delay again.
  my ($self,$delay,$rand,$resend) = @_;

  $self->{delay} = abs($delay) if defined $delay;
  $self->{resend} = abs($resend) if defined $resend;
  $self->{rand} = abs($rand) if defined $rand;
  ($self->{delay},$self->{resend},$self->{rand});
  }

sub count
  {
  # Sets the count. If != 1, the outgoing signal will be resent coun() times,
  # each time delayed by a bit specified with delay(). A count of -1 means
  # infinitely.

  my $self = shift;

  if (defined $_[0])
    {
    $self->{count} = shift;
    }
  $self->{count};
  }
  
sub once
  {
  my $self = shift;

  $self->{once} = ($_[0] ? 1 : 0) if @_ > 0;
  $self->{once};
  }

sub invert
  {
  my $self = shift;

  $self->{invert} = $_[0] ? 1 : 0 if @_ > 0;
  $self->{invert};
  }

sub fixed_output
  {
  my $self = shift;

  $self->{fixed_output} = shift if @_ > 0;
  $self->{fixed_output};
  }

1;

__END__

=pod

=head1 NAME

Game::3D::Link - link two or more objects together by a signal-relay chain

=head1 SYNOPSIS

	use Game::3D::Object;
	use Game::3D::Link;

	# send signal straight through
	my $link = Game::3D::Link->new();

	my $src = Game::3D::Object->new();
	my $dst = Game::3D::Object->new();

	$src->link ($dst, $link);

=head1 EXPORTS

Exports nothing on default.

=head1 DESCRIPTION

Represents a link between two objects and allows relaying a signal between
them.

A link has one (or more) inputs, and one (or more) outputs. Signals are send
to the inputs via calling a subroutine (any of on(), off(), flip(), or
signal()), and the signal will effect the state of the input. Each input will
remember it's state and is per default in the off state.

When all the inputs are in the the same state, the specified signal (default
is the state the inputs are in) is sent to all the outputs.

This means a link acts like an AND gate, only if all the inputs are in the
same state, it triggers. Note that there is no need for an OR type of link,
since you can simple link multiple objects via one link per object to the
same target, and if only one of the objects sends a signal, the signal would
arrive at the target.

=head1 METHODS

=over 2

=item timer_provider

	Game::3D::Link::timer_provider( $class );

You need to call this before any link with delay will work. Pass as argument
a classname or an object reference. This works best when you pass an
SDL::App::FPS object :)
	
	my $app = SDL::App::FPS->new();
	Game::3D::Link::timer_provider( $app );

=item new()

	my $link = Game::3D::Link->new( @options );

Creates a new link.

=item is_active()

	$link->is_active();

Returns true if the link is active, or false for inactive. Inactive links will
not relay signals, but the will still maintain their inputs.

=item activate()

	$link->activate();

Set the link to the active state. Newly created links are always active.

=item deactivate()
	
	$link->deactivate();

Set the link to inactive. Newly created ones are always active. Inactive links
will not relay signals until they are activated again, but they will maintain
their input states properly while inactive.

=item id()

Return the link's unique id.

=item name()

	print $link->name();
	$link->name('new name');

Set and/or return the link's name. The default name is the last part of
the classname, uppercased, preceded by '#' and the link's unique id.

=item signal()

	$link->signal($input_id,$signal);
	$link->signal($self,$signal);

Put the signal into the link's input. The input can either be an ID, or just
the object sending the signal. The object needs to be linked to the input
of the link first, by using L<link()>, or L<add_input()>.

=item add_input()

	$link->add_input($object);

Registers C<$object> as a valid input source for this link. See also L<link()>.

Do not forget to also register the link C<$link> as output for C<$object> via
C<$object->add_output($link);>. It is easier and safer to just use
C<$link->link($src,$dst);>, though.

=item add_output()

	$link->add_output($object);

Registers C<$object> as an output of this link, e.g. each signal the link
relays will also be sent to this object. See also L<link()>.

Do not forget to also register the link C<$link> as input for C<$object> via
C<$object->add_input($link);>. It is easier and safer to just use
C<$link->link($src,$dst);>, though.

=item link()

	$link->link($src,$dest);

Is a combination of L<add_input()> and L<add_output()>, e.g links the
source object via this link to the destination object. If the link was
connecting other objects beforehand, these connections will also remain.

=item count()

	$link->count(2);

Sets the count of how many times the incoming signal is sent out. Default is
1. This acts basically as a multiplier, setting it to 2 will for instance
send each incoming signal two times out, with a delay in between. The
delay can be set with L<delay()>.

Returns the count.

=item delay()

	$link->delay(2000);		# 2 seconds
	$link->delay(1000,500);		# 1 second, and then 1/2 second
	$link->delay(1000,500,200);	# 1s, 1/2s, and both of them with
					# randomized by +/- 200 ms

Sets the delay between the receiving of the signal and it's relaying. The
default for this is 0. Also sets the delay between each consecutive relay
if count() is different than 1. The third parameter is an optional
random offset applied to both delays.

Returns a list of (first_delay, resend_delay, random_offset).

=item once()

	if ($link->once()) { ... }		# return true if one-time link
	$link->once(1);				# enable one-time sending
	$link->once(0);				# disable

Sets the one-time flag of the link. If set to a true value, the link will
only re-act to the first signal, and then deactivate itself.

If the link is set to send for each incoming signal more than one signal (via
delay()), they still will all be sent. Also, each of the outputs of the link
will receive the signal. The once flag is only for the incoming signals, not
how many go out.

You can enable the link again (with L<activate()>, and it will once more work
on one incoming signal.

Default is off, e.g. the link will work on infinitely many incoming signals.

Returns the once flag.

=item fixed_output()

	if (defined $link->fixed_output()) { ... }
	$link->fixed_output(undef);			# disable
	$link->fixed_output(SIGNAL_ON);			# always send ON

Get/set the fixed output signal. If set to undef (default), then the input
signal will be relayed through (unless L<invert()> was set, which would
invert the input before sending it out), if set to a specific value, this
set signal will always be sent, regardless of the input signal or the invert()
flag.

=back

=head1 AUTHORS

(c) 2003, Tels <http://bloodgate.com/>

=head1 SEE ALSO

L<Game::3D::Thingy>, L<SDL:App::FPS>, L<SDL::App> and L<SDL>.

=cut

