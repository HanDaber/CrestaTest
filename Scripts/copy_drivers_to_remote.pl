#! /usr/bin/perl
#
# TODO's:
#	- Refactor out repeated code
#
# This script copies the specified or latest (if unspecified) driver package to remote. 
# It optionally extracts the copied package with the parameter 'extract'
#
# -Dan Haber 
# [ Dec. 2, 2011 ] - Created
# [ Jan. 27, 2012 ] - Refactoring, added extraction functionality
#
############################################# Use
use strict;
use warnings;
use lib qw(../Modules/ Modules/);
use Debug;

############################################# My
my $remote = $ARGV[0];
my $spec_ver = $ARGV[1] || "latest";
my $option_flag = $ARGV[2] || "none";
my $path = "../InstallationKits/DriverPackage"; #TODO: put path in config? (XML)
my @files = glob $path."/driverPackage_*.zip";
my ($ssh, $scp, $cmd, $ret);
my $exists;
my $version;
my $latest_version = "1";
my $remote_dir = "Drivers";
my @userhost = ();

############################################# Functions
if(!$remote) {
	Debug->error("Please provide a host (e.g. \"test\@10.10.10.123\") and optional driver version (e.g. \"123\" or \"latest\"), plus \"e\" to extract @ remote\n");
}
else {
	$version = prepare_version();
	@userhost = split(/@/, $remote);
	
	my $mkdir = "mkdir ".$remote_dir;
	$ssh = "ssh -2 ".$userhost[0]."\@".$userhost[1]." ".$mkdir.";";
	$scp = "scp ".$path."/driverPackage_".$version.".zip ".$remote.":~/".$remote_dir."/";
	Debug->info("chosen version: ".$version) if($version);
	run_copy($ssh, $scp);# unless $exists eq 0;
	
	my $extract = "../Utilities/7za x -y ".$remote_dir."/driverPackage_".$version.".zip -o".$remote_dir."/".$version;
	$ssh = "ssh -2 ".$userhost[0]."\@".$userhost[1]." ".$extract.";";
	run_extract($ssh) if $option_flag eq "e";
}

############################################# Subs
sub run_copy {
	$cmd = shift;
	$ret = system($cmd);
	Debug->error("SSH returned ".$ret) if $ret eq 65280;
	
	$cmd = shift;	
	$ret = system($cmd);
	Debug->error("SCP returned ".$ret) if $ret eq 256;
	
	Debug->success("Copied driver version ".$version." to ".$remote) if $ret eq 0;
}

sub run_extract {
	$cmd = shift;
	Debug->action("extract cmd: ".$cmd);
	$ret = system($cmd);
	Debug->error("extract returned ".$ret) if $ret eq 65280 || $ret eq 512;
	Debug->success("extraction complete") if $ret eq 0;
}

sub prepare_version {
	# Print driver directory
	Debug->info("Current directory: ".$path);
	
	# If spec_ver == "latest"
	if( $spec_ver eq "latest" ) {
		foreach( @files ) {
			$_ =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/;
			if($_ > $latest_version) { $latest_version = $_; }
		}
		print(" $latest_version\n");
		return $latest_version;
	} 
	else {
		foreach( @files ) {
			$_ =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/;
			$exists = 0;
			if($_ eq $spec_ver) { 
				$exists = 1; 
				return $_;
			}
		}
		if($exists eq 0) { 
			Debug->error("The specified version: ".$spec_ver." cannot be found ($exists)."); 
			list_vers();
		}
	}
}

sub list_vers {
	# List available versions
	Debug->action("All available versions:");
	foreach my $file (@files) {
		get_ver($file); # TODO: refactor out multiple uses of regex
		print(" $file \t");
	}
}

sub get_ver { # TODO: Y U NO WORK?
  my $text = shift;
  $text =~ s/$path\/driverPackage_([0-9]+)\.zip/$1/;
  return $text;
}
