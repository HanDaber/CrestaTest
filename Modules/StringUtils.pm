#!/usr/bin/perl
package StringUtils;

################# Use:
use strict;
use warnings;
use Debug;

################# My:
my $var;

################# Sub:
sub new {
	# Debug->info($_[0]);
	
	my $object = shift;
	my $class = ref $object || $object;
	my $self = {};
	
	bless $self, $class;
	return $self;
}

# Separate path from file name
sub file_path {
	my $class = shift;
	my $path_to_file = shift;
	my( $path, $file );
	
	if( $path_to_file =~ m/(([a-zA-Z0-9_\-]+\/)+)([a-zA-Z0-9_\-]+\.[a-zA-Z0-9]{1,3})/ ) {
		# Path/File:
		$path = $1;
		$file = $3;
		
	} else {
		$path = "/";
		$file = $path_to_file;
	}
	return( $path, $file );
}

sub dest_string {
	my $class = shift;
	my $details = shift;

	return $details->{username}."\@".$details->{ip};
}

sub dos_path {
	my $unix_path = shift;
	if( ref($unix_path) eq __PACKAGE__ ) {$unix_path = shift;}
	my $dos_path = $unix_path;
	$dos_path =~ s#/#\\#g;
	return $dos_path;
}

return 1;