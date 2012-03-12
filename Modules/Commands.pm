#!/usr/bin/perl
package Commands;

################# Use:
use strict;
use warnings;
use Configs;
use StringUtils;

################# My:
my $command = \&command;
my $program = \&program;
my $ssh = \&ssh;
my $is_local = \&is_local;
my $ret;
my $farm = Configs->farm();
my $monitor_ip = $farm->{monitor}->{ip};
my $string_utils = StringUtils->new();

################# Sub:
sub new {
	# Debug->info($_[0]);
	my $object = shift;
	my $class = ref $object || $object;
	my $self = {};
	
	bless $self, $class;
	return $self;
}

sub put_ref {return \&scp_put;}
sub scp_put { 
	my( $dest_string, $file_path, $remote_path ) = (shift,shift,shift); 
	return system("scp ".$file_path." ".$dest_string.":~/".$remote_path);
}

sub get_ref {return \&scp_get;}
sub scp_get {
	my( $dest_string, $remote_path, $local_path ) = (shift,shift,shift); 
	return system("scp ".$dest_string.":~/".$remote_path." ".$local_path);
}

sub compress_ref {return \&zip_compress;}
sub zip_compress { 
	my( $dest_string, $zip_name, $files ) = (shift,shift,shift); 
	if( $is_local->($dest_string) ) {
		Debug->info("Local"); 
		return system("./7za.exe a -y ".$zip_name." ".$files);
	} else {
		Debug->info("Remote");
		return system($ssh->($dest_string)."./7za.exe a -y ".$zip_name." ".$files);
	}
}

sub extract_ref {return \&zip_extract;}
sub zip_extract { 
	my( $dest_string, $zip_name, $dest_dir ) = (shift,shift,shift);
	my( $x_e, $e_dir, $dir );
	if( defined $dest_dir ) { $dir = $string_utils->dos_path($dest_dir); $x_e = "x"; $e_dir = "-o".$dir; }
	else { $x_e = "x"; $e_dir = ";"; }
	if( $is_local->($dest_string) ) {
		Debug->info("Local");
		return system("./7za.exe ".$x_e." -y ".$zip_name." ".$e_dir);
	} else {
		Debug->info("Remote");
		return system($ssh->($dest_string)."./7za.exe ".$x_e." -y ".$zip_name." ".$e_dir);
	}
}

sub remove_ref {return \&file_remove;}
sub file_remove {
	my( $dest_string, $file_name ) = (shift,shift);
	print "remove ".$file_name."\n";
	if( $is_local->($dest_string) ) {
		Debug->info("Local");
		return system("rm -r ".$file_name);
	} else {
		Debug->info("Remote");
		return system($ssh->($dest_string)."rm -r ".$file_name);
	}
}

sub sys {
	foreach(@_){print "sys prm ".$_."\n";}
	my( $dests, $cmd ) = (shift,shift);
	my $sys = &sys_ref();
	my $ret;
	Debug->action($cmd);
	# Debug->info("Destination: ".ref($dests).";\n 
		# Command: ".$cmd.";\n");
	$ret = $dests->each($sys, $cmd);
	return $ret;
}
sub sys_ref {return \&sys_cmd;}
sub sys_cmd {
	my( $dest_string, $command ) = (shift,shift);
	if( $is_local->($dest_string) ) {
		Debug->info("Local");
		return system($command);
	} else {
		Debug->info("Remote");
		return system($ssh->($dest_string).$command);
	}
}

sub ssh {my $dest_string = shift; return "ssh -2 ".$dest_string." ";}
sub is_local {
	my $dest_string = shift;
	if($dest_string =~ m/$monitor_ip/) {return 1;}
	else {return 0;}
}









############################ BEING DEPRECATED: #################################


sub command {
	my $dest = shift;
	my $remote = shift;
	my $prm = shift;
	my $prm_len;
	my $cmd;
	# my $wait = "--wait";
	my $wait = "--hide";
	
	Debug->yell($prm);
	$cmd = "cygstart ".$wait." ./commands.cmd ";
	
	if( $remote eq 1 ) { 
		my $ssh = &ssh_wrap($dest);
		# Debug->action($ssh.$cmd.$prm." \n\@ ".$dest->{ip});
		$ret = system($ssh.$cmd.$prm);
	}
	else { 
		if( $prm =~ m/^scp_send/ ) { $prm = join(" ", $prm, $dest->{username}."\@".$dest->{ip}.":~/"); }
		Debug->action($cmd.$prm." \n\@ ".$dest->{ip});
		$ret = system($cmd.$prm);
	}
	
	return $ret;
}

sub program {
	my $dests = shift;			# Hash of computers
	my $prog = shift;			# Which program/command was called (matches in commands.cmd)
	my $remote;
	my $single_dest_name = (keys %{$dests})[0];
	my $dest_ip = $dests->{$single_dest_name}->{ip};
	
	# Debug->info("dests ip: ".$dest_ip);
	
	if( scalar(keys %{$dests}) eq 1 and $dest_ip eq $monitor_ip ) {
		$remote = 0;
	} elsif( $prog eq "scp_send" ) {
		$remote = 0;
		# $prog = "scp";
		# push(@_, "dest");
	} else {
		$remote = 1;
	}
	
	Debug->info("Remote") if $remote eq 1;
	Debug->info("Local") if $remote eq 0;
	
	my $cmd = join( " ", $prog, @_ );
	# Debug->prompt($cmd);
	return $dests->each($command, $remote, $cmd);
}

# shift contains the $dests hash:
# sub player { return $program->(shift, "player", @_); }
# sub mce { return $program->(shift, "mce", @_); }
# sub devcon { return $program->(shift, "devcon", @_); }
# sub zip { return $program->(shift, "7zip", @_); }
# sub rm { return $program->(shift, "rm", @_); }
sub mk { return $program->(shift, "mk", @_); }
# sub scp { return $program->(shift, "scp", @_); }
# sub scp_send { return $program->(shift, "scp_send", @_); }

sub ssh_wrap {
	my $destn = shift;
	if( $destn eq __PACKAGE__ ) {Debug->info("ssh wrap shifted"); $destn = shift;}
	# Debug->dump("ssh wrap destn", $destn);
	return "ssh -2 ".$destn." ";
}


return 1;