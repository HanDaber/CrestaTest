#!/usr/bin/perl
package Client;

################# Use:
use strict;
use warnings;
use Debug;

################# My:
my $client_obj;
my($package, $filename, $line) = caller;
# my $this = &new($0);
my $self;
################# Sub:
sub new {
	foreach( @_ ){ Debug->info($_); }
	my $object = shift;
	my $class = ref $object || $object;
	
	$self = {
		do 		=> \&do,
		process => \&process
	};
	
	# Debug->dump("self", $self);
	
	bless $self, $class;
	return $self;
}

sub do {
	my $class = shift;
	foreach( @_ ) { Debug->dump("Client->do param", $_); }
	my $blah = {
		a => "Client->do",
		b => "complete"
	};
	$class->send_back($blah);
	return 1;
}

sub process {
	my $class = shift;
	my $response_object = shift;
	my $instructions = $response_object->{instructions}; # Change this data structure
	my $parameters = $response_object->{parameters};		 # not to contain 'reply_to_client'
	Debug->action($instructions);
	Debug->action($parameters);
	
	$class->do($instructions, $parameters);
}

sub send_back {
	Debug->yell("Client->send_back was called, yo!");
	return 1;
}

return 1;