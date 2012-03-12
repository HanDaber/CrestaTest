#!/usr/bin/perl
package Monitor;

################# Use:
use strict;
use warnings;
use Debug;
use XML::Simple;

################# My:
my $xml = XML::Simple->new();
my $farm_config = $xml->XMLin('Config/farm_config.xml');
my $monitor_config = $farm_config->{monitor};
my $monitor_obj;

################# Sub:
sub new {
	foreach( @_ ){ Debug->info($_); }
	my $object = shift;
	my $class = ref $object || $object;
	
	my $this = generate_object();
	
	# Debug->dump("this monitor",$this);
	
	my $self = {
		monitor => $this #,
		# clients => $clients,
		# servers => $servers
	};
	
	# Debug->dump("self", $self);
	
	bless $self, $class;
	return $self;
}

sub generate_object {
	# Strip away everything which is not a properly formatted hash (e.g. 'files_dir', 'null')
	# while( my($name, $hash) = each(%$_) ) {
		# if( (ref $hash ne 'HASH') or ($hash->{ip} !~ /(\d{1,3}\.){3}\d/) ) {
			# delete $_->{$name};
		# }
	# }	
	# Create/format the objects to return in new->$self:
	$monitor_obj = $farm_config->{monitor};
	# $monitor_obj->{dir} = $farm_config->{monitor}->{files_dir};
	return $monitor_obj;
}

return 1;