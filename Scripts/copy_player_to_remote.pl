#! /usr/bin/perl

=begin comments

TODO's:
	- Refactor out repeated code

This script copies the specified or latest (if unspecified) driver package to remote. 

-Dan Haber 
[ Dec. 2, 2011 ] - Created

=end comments
=cut


use strict;
use warnings;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

my $remote = $ARGV[0];
my $spec_ver = $ARGV[1];
my $playerpath = "InstallationKits/B3Tuner/TestBuild/Player"; #TODO: put path in config? (XML)
my $command = "";
my $return = "";
my $file = "";
my $version = "";
my $latest_version = "1";

my @userhost = ();

if(!$remote) {
	print BOLD RED ON_YELLOW "\n Please provide a host (e.g. \"name\@10.10.10.123\") and optional player version (e.g. \"x86\") (defaults to x64) \n";
}
else {
	run_commands();
}

sub run_commands {
	@userhost = split(/@/, $remote);
	
	# Print player directory
	my $dir = $playerpath; 
	$dir =~ s/\/cygdrive\/c//;
	print CYAN "\n Player directory: $dir";
	
	# If a version was specified with script call
	if($spec_ver) { 				#copy that version 
		print MAGENTA "\n\n Specified player: X86";
		
		$command = "ssh -2 ".$userhost[0]."\@".$userhost[1]." mkdir player;";
		$return = system($command);
		$command = "scp $playerpath/CrestatechSetup.msi $remote:~/player/";	
		$return = system($command);
		$command = "ssh -2 ".$userhost[0]."\@".$userhost[1]." chmod 0777 player/*;";
		$return = system($command);	
		print GREEN "\n Copied X86 player to $remote\n" if($return == 0);
	}
	else {							# copy latest
		print MAGENTA "\n\n Specified player: X64:";
		
		$command = "ssh -2 ".$userhost[0]."\@".$userhost[1]." mkdir player;";
		$return = system($command);
		$command = "scp $playerpath/CrestatechSetupX64.msi $remote:~/player/";	
		$return = system($command);
		$command = "ssh -2 ".$userhost[0]."\@".$userhost[1]." chmod 0777 player/*;";
		$return = system($command);		
		print GREEN "\n Copied X64 player to $remote\n" if($return == 0);
	}
	
}

