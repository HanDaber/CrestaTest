#!/usr/bin/perl

################################################ Use
use strict;
use warnings;
use lib qw(Modules/);
use Debug;
use Configs;
use Farm;

################################################ My
my @args = @ARGV;
my ($params, $ret, $cmd);
my $farm = Farm->new();
my ($monitor, $clients, $servers) = ($farm->{monitor}, $farm->{clients}, $farm->{servers});
my $setup_files = Configs->setup_files();
my $files_to_copy = Configs->files();
my $zip_name = Configs->files("name");
my $driver_version = "latest";
my $parameturd = "start";
my $chosen = \&chosen;

################################################ Fn
Debug->section("Hello.");
if( $chosen->("debugs")   ) {&show_debugs;}
if( $chosen->("farm")     ) {&show_farm;}
# DNE::&handle_params();
if( $chosen->("setup")    ) {&set_up_clients;}
if( $chosen->("drivers")  ) {&send_driver;}
# if( $chosen->("commands") ) {&send_commands("cygstart perl Scripts/test_mce.pl");}
# &start_server();
if( $chosen->("player")   ) {&app_ctrl("mce");}
# DNE::&run_tests(1);

################################################ Sub
sub chosen {
	# foreach(@_){Debug->action($_);}
	my $task = shift;
	my $bool;
	foreach( @args ) {
		if( ($_ =~ m#($task)#g) || ($_ eq "all") ) {return 1;}
		else {$bool = 0;}
	}
	return $bool;
}

sub show_debugs {
	Debug->section("Debug Styles:");
	
	my @debug_styles = qw(info action error warning success yell);
	foreach( @debug_styles ) { Debug->$_($_); }
	Debug->dump("dump", "dump");
}

sub show_farm {
	Debug->section("PC farm snapshot:");
	
	Debug->dump("Monitor", $monitor);
	Debug->dump("Servers", $servers);
	Debug->dump("Clients", $clients);
}

sub set_up_clients {
	Debug->section("Set up clients:");
	
	my ($zip, $xfer, $xtract);
	my $files = $files_to_copy;
	
	# Send zip utility
	$xfer = $clients->put("7za.exe");
	Debug->info("xfer ret: ".$xfer);

	# Compress our local files for xfer
	$zip = $monitor->compress($zip_name, @{$files});
	Debug->info("zip ret: ".$zip);

	if( $zip eq $zip_name ) {
		# Send, extract and remove zip on each client
		$xfer = $clients->put($zip);
		$xtract = $clients->extract($zip);
		$ret = $clients->remove($zip);
	}
	
	# Clean up local temp file
	$ret = $monitor->remove($zip);
	Debug->info($ret);
}

sub send_driver {
	Debug->section("Send driver:");
	
	# $driver_version = Debug->prompt("Driver version to use: ");
	
	my($chosen_driver, $number, $file) = $farm->prepare_version($driver_version);
	Debug->yell("Using driver version: ".$number);
	
	$ret = $clients->put($chosen_driver);
	Debug->info($ret);
	
	$ret = $clients->extract($file, "Drivers\_".$number."/");
	Debug->info($ret);
	
	$ret = $clients->remove($file);
	Debug->info($ret);
}

sub install_driver {
}

# sub start_server {
	# Debug->section("Start server:");
	
	# $cmd = "cygstart perl Modules/TCPSock.pm start";
	# Debug->action($cmd);
	# $ret = system($cmd);
	# Debug->info("fork server return: ".$ret);
# }

sub app_ctrl { # <-- WORKING HERE and it is broken :(
	Debug->section("App control:");
	
	my $cmd;
	
	$params = "/nostartupanimation /homepage:Options.Home.xml /PushStartPage:True"; # Put in cfg
	
	$cmd = $clients->mce($parameturd, $params);
	Debug->info($cmd);
	# $cmd = $monitor->mce($parameturd, $params);
	# Debug->info($cmd);
	
	if( $parameturd eq "start" ) {
		Debug->info("Waiting for player to open...");
		sleep 12;
	}
	
	$cmd = "cygstart perl Scripts/test_mce.pl";
	$ret = $clients->sys($cmd);
	
	# sleep 60;
	# $cmd = $clients->mce("stop");
	# Debug->info($cmd);
	if( 0 ) {
		my $driver_uninstall = \&uninst;
		$monitor->each($driver_uninstall);
		# $driver_uninstall->();
		
		# $cmd = $monitor->sys("cygstart devmgmt.msc");
		# sleep 1;
		# my $uninst = $monitor->apps("MMCMainFrame", "SysTreeView", "{DOWN 14}{RIGHT}{DOWN}{APP}{DOWN 3}{ENTER}{SPACE}{ENTER}");
		# Debug->prompt("WHENEVER You're ReAdY");
		# my $kill = $monitor->sys("TSKILL mmc");
	}
	sleep 1;
	if( 0 ) {
		my $driver_install = \&inst;
		$monitor->each($driver_install);		
		# $driver_install->();
		
		# $cmd = $monitor->sys("cygstart devmgmt.msc");
		# sleep 1;
		# my $refresh = $monitor->apps("MMCMainFrame", "SysTreeView", "{APP}{DOWN}{ENTER}");
		# sleep 3;
		# my $inst = $monitor->apps("MMCMainFrame", "SysTreeView", "{DOWN 12}{RIGHT}{APP}{DOWN}{ENTER}{DOWN}{ENTER}C:\\Users\\dhaber\\Desktop\\driverPackage_178\\DriversSources\\bin\\release{ENTER}");
		# my $wait = $monitor->wait("MMCMainFrame", "Update Driver", "NativeHWNDHost");
		# Debug->prompt("WHENEVER You're ReAdY");
		# my $ok = $monitor->apps("MMCMainFrame", "SysTreeView", "{ENTER}");
		# my $kill = $monitor->sys("TSKILL mmc");
	}
	# my $wait = $monitor->wait("MMCMainFrame", "Update Driver", "NativeHWNDHost");
	# Debug->info($cmd);
}
sub uninst {	
	$cmd = $monitor->sys("cygstart devmgmt.msc");
	Debug->prompt("WHENEVER You're ReAdY");
	sleep 1;
	my $uninst = $monitor->apps("MMCMainFrame", "SysTreeView", "{DOWN 14}{RIGHT}{DOWN}{APP}{DOWN 3}{ENTER}{SPACE}{ENTER}");
	Debug->prompt("WHENEVER You're ReAdY");
	my $kill = $monitor->sys("TSKILL mmc");
}
sub inst {
	$cmd = $monitor->sys("cygstart devmgmt.msc");
	Debug->prompt("WHENEVER You're ReAdY");
	sleep 1;
	my $refresh = $monitor->apps("MMCMainFrame", "SysTreeView", "{APP}{DOWN}{ENTER}");
	sleep 3;
	my $inst = $monitor->apps("MMCMainFrame", "SysTreeView", "{DOWN 12}{RIGHT}{APP}{DOWN}{ENTER}{DOWN}{ENTER}C:\\Users\\dhaber\\Desktop\\driverPackage_178\\DriversSources\\bin\\release{ENTER}");
	Debug->prompt("WHENEVER You're ReAdY");
	# my $ok = $monitor->apps("MMCMainFrame", "SysTreeView", "{ENTER}");
	my $kill = $monitor->sys("TSKILL mmc");
}

sub send_commands {
	Debug->section("Send commands:");
	
	my $cmd = shift || "ls";
	$ret = $clients->sys($cmd);
	# $ret = $clients->each($sys);
	Debug->info("Commands ret: ".$ret);
}
