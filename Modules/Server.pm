#!/usr/bin/perl
package Server;

################# Use:
use strict;
use warnings;
use Debug;
use XML::Simple;

################# My:
my $xml = XML::Simple->new();
my $farm_config = $xml->XMLin('Config/farm_config.xml');
my $server_obj;

################# Sub:
sub new {
	foreach( @_ ){ Debug->info($_); }
	my $object = shift;
	my $class = ref $object || $object;
	
	my $this = generate_object();
	
	Debug->dump("this server",$this);
	
	my $self = {
		server => $this #,
		# clients => $clients,
		# servers => $servers
	};
	
	# Debug->dump("self", $self);
	
	bless $self, $class;
	return $self;
}

sub generate_object {
	# Create/format the objects to return in new->$self:
	$server_obj = $farm_config->{servers}->{server};
	$server_obj->{dir} = $farm_config->{servers}->{files_dir};
	return $server_obj;
}

return 1;