#! /usr/bin/perl
#
# TODO's:
#	- Refactor out repeated code
#	- Make generic zip/trnsfer/unzip for any type of file (driver/script...)
#
# This script copies the specified file to remote. 
# Branched from copy_driver_to_remote.pl
#
# -Dan Haber 
# [ Jan. 31, 2012 ] - Created
#
############################################# Use
use strict;
use warnings;
use lib qw(../Modules/ Modules/);
use Debug;

############################################# My
my $path_to_file = shift;
my $remote = shift;
my $remote_dir = shift;# || "copied_from_remote/";
# my $dir = $path_to_file =~ s/^([a-zA-Z0-9_\/]+)[a-zA-Z0-9_]+\.[a-z0-9]{1,3}/$1/i; #TODO: fix this
my ($mkdir, $ssh, $scp, $cmd, $ret);
my @userhost = split(/@/, $remote);

############################################# Functions
if(!$path_to_file or !$remote) {
	Debug->error("Please provide a full path to local file and a host (e.g. \"test\@10.10.10.123\")\n");
}
else {	
	if( !$remote_dir || $remote_dir eq "" ) {
		# Debug->error("NO REMOTE DIR");
		$mkdir = " exit;";
		$remote_dir = ";";
	} else {
		$mkdir = " mkdir ".$remote_dir.";";
	}
	$ssh = "ssh -2 ".$userhost[0]."\@".$userhost[1].$mkdir;
	$scp = "scp ".$path_to_file." ".$remote.":~/".$remote_dir;
	run_copy($scp); # or die Debug->error("run_copy: $!");
}

############################################# Subs
sub run_copy {
	# $cmd = shift;   # To test SSH connection
	# $ret = system($cmd);
	# Debug->error("SSH returned ".$ret) if $ret eq 65280;
	
	$cmd = shift;	
	Debug->action($cmd);
	$ret = system($cmd);
	Debug->error("SCP returned ".$ret) if $ret ne 0;
	Debug->success("SCP returned ".$ret) if $ret eq 0;
	
	# Debug->success("Copied ".$path_to_file." to ".$remote) if $ret eq 0; # make silent and return a success code instead?
}
