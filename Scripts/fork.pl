#!/usr/bin/perl
# package Name;

################# Use:
use strict;
use warnings;
use lib qw(../Modules/ Modules/);
use Debug;
use Farm;

################# My:
my $num = $ARGV[0];
my $cmd = $ARGV[1];
my $wait;
my @array = qw(fdgfag fdag dfg afdg erg rg aerg srth sfrjh);
my @childs;
my $farm = Farm->new();
my ($monitor, $clients, $servers) = ($farm->{monitor}, $farm->{clients}, $farm->{servers});

################# Sub:
for( my $i=0; $i<$num; $i++ ) {
	Debug->info($i."/".$num);
	my $pid = fork();
	if( $pid ) { # parent
		push( @childs, $pid );
	} elsif( $pid == 0 ) { # child
		Debug->action("Doing the thing...");
		print "@array\n\n";
		sleep 5;
		Debug->yell($cmd);
		exit(0);
	} else {
		die Debug->error("Couldn’t fork: ".$!);
	}
}

foreach (@childs) {
	$wait = waitpid($_, 0);
	print "\tPID ".$wait." done\n\n";
}

Debug->yell("Its over, man!");

sub method {}

# return 1;