#!/usr/bin/perl
package CTCTest;

################# Use:
use strict;
use warnings;
use Debug;

################# My:
my $self;

################# Sub:
sub new {
	foreach( @_ ){ Debug->info($_); }
	my $object = shift;
	my $class = ref $object || $object;
	
	$self = {
		status => \&reply # Uhh, doesn't find method 'status' when called from TCPSock(??)
	};
	
	# Debug->dump("self", $self);
	
	bless $self, $class;
	return $self;
}

sub status {
	foreach( @_ ) { Debug->dump("CTCTest reply", $_); }

	my $test = {
		instructions => "DO SOMETHING",
		parameters	 => "A, B, C"
	};
	return $test;
}

return 1;