#!/usr/bin/perl -w

use Test::More tests => 11;
use strict;

BEGIN
  {
  $| = 1;
  unshift @INC, '../blib/lib';
  unshift @INC, '../blib/arch';
  unshift @INC, '.';
  chdir 't' if -d 't';
  use_ok ('Game::3D::Signal', 
    qw/ SIGNAL_ON SIGNAL_OFF STATE_OFF STATE_ON SIGNAL_FLIP
	SIGNAL_LEFT SIGNAL_RIGHT SIGNAL_UP SIGNAL_DOWN
	SIGNAL_OPEN SIGNAL_CLOSE SIGNAL_ACTIVATE SIGNAL_DEACTIVATE
	STATE_FLIP
	SIGNAL_LEVEL_WON
	SIGNAL_LEVEL_LOST
	/);
  }

can_ok ('Game::3D::Signal', qw/ 
  invert
  /);

is (Game::3D::Signal->invert(SIGNAL_ON), SIGNAL_OFF, 'ON => OFF');
is (Game::3D::Signal->invert(SIGNAL_OFF), SIGNAL_ON, 'OFF => ON');
is (Game::3D::Signal->invert(SIGNAL_RIGHT), SIGNAL_LEFT, 'R => L');
is (Game::3D::Signal->invert(SIGNAL_LEFT), SIGNAL_RIGHT, 'L => R');
is (Game::3D::Signal->invert(SIGNAL_OPEN), SIGNAL_CLOSE, 'OPEN => CLOSE');
is (Game::3D::Signal->invert(SIGNAL_CLOSE), SIGNAL_OPEN, 'CLOSE => OPEN');
is (Game::3D::Signal->invert(SIGNAL_ACTIVATE), SIGNAL_DEACTIVATE, 'A => DE');
is (Game::3D::Signal->invert(SIGNAL_DEACTIVATE), SIGNAL_ACTIVATE, 'DE => A');
is (Game::3D::Signal->invert(SIGNAL_FLIP), SIGNAL_FLIP, 'FLIP => FLIP');

