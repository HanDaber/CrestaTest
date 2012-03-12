#!/usr/bin/perl
package Connection;

use strict;
use warnings;
use Debug;

my $number_of_connections = 0;

# Construct a new connection object
sub new {
	my $object = shift;
	my $class = ref($object) || $object;
	my $network_name = $_[0];

	my $check = check_connection($network_name);
	if (!$check) { return 0; }
	
	my $ret = system("ssh -2 ".$network_name." ls;");
	if( $ret eq 0 ) {
		Debug->success("Connection with ".$network_name." has been established.");
	}
	
	my $self = {
		check => $check,
		network_name => $network_name
	};
	
	$number_of_connections++;
	
	bless $self, $class;
	return $self;
}
# Check to see if connection is alive
sub check_connection { 
	if ($_[0]) { return $_[0]; }
	else { return 0; }
}

# Send something through a connection - $conn_1->transfer("blah");
sub transfer { 
	Debug->action(my $ret = $_[1]." sent to ".$_[0]->{network_name}); 
	return $ret;
}

sub length { return $number_of_connections; }

sub DESTROY { --$number_of_connections; }

return 1;