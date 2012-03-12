#!/usr/bin/perl

#
# TODO: take out dependencies on farm,
# call by Transfer->to($file, $dest) || ->from(...) || ->driver($orig, $dest)...
#

package Transfer;

################# Use:
use strict;
use warnings;
use Debug;
use Farm;

################# My:
my $pc_farm = Farm->new();

################# Sub:
sub copy_file {
	foreach( @_ ){ Debug->info($_); }
	my $object = shift;
	my($file, $origin, $destination) = @_;
	
	my $origin_path = $origin->{dir};
	# $origin_path =~ s/C://i;
	my $destination_path = $destination->{dir};
	# $destination_path =~ s/C:/cygdrive\/c/i;
	
	Debug->dump("origin",$origin);
	Debug->dump("destination",$destination);
	
	my $from = $origin;
	my $to = $destination;
	
	# Strip away everything which is not a properly formatted hash (e.g. 'files_dir', 'null')
	foreach( $from, $to ) {
		while( my($name, $obj) = each(%$_) ) {
			if( (ref $obj ne 'HASH') or ($obj->{ip} !~ /(\d{1,3}\.){3}\d/) ) {
				delete $_->{$name};
			}
		}
	}
	
	Debug->dump("from",$from);
	Debug->dump("to",$to);
	
	foreach my $f ( keys %$from ) {
		foreach my $t ( keys %$to ) {
			Debug->action("Copy ".$file." from ".$f."/".$origin_path." to ".$t."/".$destination_path);
		}
	}
	
	# my @commands = (
		# "ssh -2 ".$destination." mkdir ".$destination_path,
		# "scp ".$origin_path."/".$file." ".$destination.":~/".$destination_path."/"
	# );

	# foreach my $cmd ( @commands ) {
		# my $return = system($cmd);
		# print "return: ".$return."\n";
		# return $return unless $return eq 0 or 256;
	# }
	
	return 1;
}

return 1;