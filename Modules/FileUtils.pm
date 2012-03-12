#!/usr/bin/perl
package FileUtils;

################# Use:
use strict;
use warnings;
use Debug;
use Configs;
use Commands;
use StringUtils;

################# My:
my $ret;
my $setup_files = Configs->setup_files();
my $string_utils = StringUtils->new();
my $commands = Commands->new();

################# Sub:
sub new {
	# Debug->info($_[0]);
	my $object = shift;
	my $class = ref $object || $object;
	my $self = {};
	
	bless $self, $class;
	return $self;
}

sub put {
	my( $dests, $local_file_path, $remote_path ) = (shift,shift,shift || "");
	my $put = $commands->put_ref();
	my $ret;
	Debug->action("Put files");

	$ret = $dests->each($put, $local_file_path, $remote_path);
	return $ret;
}

sub get {
	my( $dests, $remote_file_path, $local_path ) = (shift,shift,shift || "");
	my $get = $commands->get_ref();
	my $ret;
	Debug->action("Get files");

	$ret = $dests->each($get, $remote_file_path, $local_path);
	return $ret;
}

sub compress {
	my( $dests, $zip_name, @files ) = (shift,shift,@_);
	my $compress = $commands->compress_ref();
	my($files_list, $ret);
	Debug->action("Compress files");

	foreach( @files ) {
		$files_list .= " ".$_;
	}
	$ret = $dests->each($compress, $zip_name, $files_list);
	if($ret eq 0){ return $zip_name; }
	else { return $!; }
}

sub extract {
	my( $dests, $zip_name, $dest_dir ) = (shift,shift,shift);
	my $extract = $commands->extract_ref();
	my $ret;
	Debug->action("Extract files");

	$ret = $dests->each($extract, $zip_name, $dest_dir);
	if($ret eq 0){ return $zip_name; }
	else { return $!; }
}

sub remove {
	my( $dests, $file_name ) = (shift,shift);
	my $remove = $commands->remove_ref();
	my $ret;
	Debug->action("Remove files");

	$ret = $dests->each($remove, $file_name);
	return $ret;
}

sub driver_install {
	foreach(@_) {Debug->yell("driver install ".$_);}
	my( $dests, $file_name ) = (shift,shift);
	my $ret;
	Debug->action("Install driver");
	
	# $ret = $dests->each($popooipoiiuiuyuygtjhgvjhgfjhgf, $file_name);
	# return $ret;
}

sub prepare_version {
	my $spec_ver = shift;
	if( ref($spec_ver) eq "Farm" ) {$spec_ver = shift;}
	Debug->info("Searching for driver: ".$spec_ver);
	my $path = "InstallationKits/DriverPackage"; #TODO: put path in config
	my @files = glob $path."/driverPackage_*.zip";
	my ($ssh, $scp, $cmd, $v);
	my $exists;
	my $latest_version = "1";
	my $remote_dir = "Drivers";

	# Print driver directory
	Debug->info("Current directory: ".$path);
	
	if( $spec_ver eq "latest" ) {
		foreach( @files ) {
			$_ =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/;
			if($_ > $latest_version) { $latest_version = $_; }
		}
		print(" $latest_version\n");
		$v = $latest_version;
	} 
	else {
		foreach( @files ) {
			$_ =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/;
			$exists = 0;
			if($_ eq $spec_ver) { 
				$exists = 1; 
				$v = $_;
				# Debug->prompt($v." ".$exists);
			}
		}
		if($exists eq 0) { 
			Debug->error("The specified version: ".$spec_ver." cannot be found ($exists)."); 
			# List available versions
			Debug->action("All available versions:");
			foreach my $file (@files) {
				$file =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/; # TODO: refactor out multiple uses of regex
				print(" $file \t");
			}
		}
	}
	return($path."/driverPackage_".$v.".zip", $v, "driverPackage_".$v.".zip");
}

return 1;