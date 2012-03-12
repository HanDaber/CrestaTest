#! /usr/bin/perl

#
# This script creates two files locally (id_rsa.pub >> authorized_keys && id_dsa.pub >> authorized_keys2)
# and copies them to the remote host's .ssh dir. 
# Then it tests the ssh connection, which should now work without entering a password.
# 
# -Dan Haber 
#	[ Dec. 1, 2011 ] - Created
#
# TO DO: delete keys after successful copy

use strict;
use warnings;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

my $remote = $ARGV[0];
my $command = "";
my $return = "";
my @userhost = ();

if(!$remote) {
	print BOLD RED ON_YELLOW "\n Please provide a host (e.g. \"name\@10.10.10.123\")\n";
}
else {
	run_commands();
}

sub run_commands {
	@userhost = split(/@/, $remote);
	
	$command = "cat ../../.ssh/id_rsa.pub >> authorized_keys; cat ../../.ssh/id_dsa.pub >> authorized_keys2;";
	# print GREEN "\nIssuing: $command\n";
	$return = system($command);
	print YELLOW "\n Created local authorized_keys\n" if($return == 0);
	
	$command = "scp ../../authorized_keys ../../authorized_keys2 $remote:~/.ssh/";	
	# print GREEN "\nIssuing: $command\n";
	$return = system($command);
	print YELLOW "\n Copied keys to $remote\n" if($return == 0);
	
	$command = "ssh -2 ".$userhost[0]."\@".$userhost[1]." ls; chmod 600 .ssh/*; exit;";
	# print GREEN "\nIssuing: $command\n";
	$return = system($command);
	print YELLOW "\n Connected successfully\n" if($return == 0);	
}

