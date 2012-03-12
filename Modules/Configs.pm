#!/usr/bin/perl
package Configs;

################# Use:
use strict;
use warnings;
use Debug;
use XML::Simple;

################# My:
my $xs = XML::Simple->new();

################# Sub:
sub files {
	# Debug->info($_[0]);
	
	my $object = shift;
	my $class = ref($object) || $object;
	my $zip_name = shift or undef;
	
	my $files_config = $xs->XMLin('Config/files_config.xml', SuppressEmpty => undef);
	# Debug->dump("files config", $files_config);
	
	if( defined($zip_name) ) { return $files_config->{zip_name}; }
	
	my $self = [];
	
	while( my($key, $val) = each( %{$files_config->{file}} ) ) {
		# Format 'dir'
		if( defined($val->{dir}) and $val->{dir} !~ m/\// ) { $val->{dir} .= "/"; }
		push(@{$self}, ($val->{dir} || "").$key);
	}
	# Debug->dump("files config formatted", $self);
	
	bless $self, $class;
	return $self;
}

sub farm {
	# Debug->info($_[0]);
	
	my $object = shift;
	my $class = ref($object) || $object;
	
	my $farm_config = $xs->XMLin('Config/farm_config.xml', SuppressEmpty => undef, KeyAttr => "name");
	
	# Debug->dump("farm config", $farm_config);
	
	my $self = $farm_config;
	
	bless $self, $class;
	return $self;
}

sub setup_files {
	# Debug->info($_[0]);
	
	my $object = shift;
	my $class = ref($object) || $object;
	
	my $setup_config = $xs->XMLin('Config/files_config.xml', SuppressEmpty => undef);
	
	my $self = $setup_config->{setup};
	# Debug->dump("", $self);
	
	bless $self, $class;
	return $self;
}

return 1;