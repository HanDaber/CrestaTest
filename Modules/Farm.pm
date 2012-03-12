#!/usr/bin/perl
package Farm;

################# Use:
use strict;
use warnings;
use Debug;
use Configs;
use FileUtils;
use StringUtils;
use Commands;
use Apps;

################# My:
my $farm_config = Configs->farm();
my $file_utils = FileUtils->new();
my $string_utils = StringUtils->new();

our @ISA = qw(Commands FileUtils Apps);

################# Fn:


################# Sub:
sub new { # Constructor
	# Debug->info($_[0]);
	
	my $object = shift;
	my $class = ref $object || $object;
	
	my $self = {
		monitor => &get_monitor(),
		clients => &get_clients(),
		servers => &get_servers()
	};
	
	bless $self, $class;
}

# Iterate a function over farm elements (Clients, Servers or Monitor)
sub each {
	my( $dest, $fn_ref, @fn_arg ) = (shift, shift, @_);

	my($ret, $dest_string);
		
	while( my( $name, $details ) = each( %{$dest} ) ) {
		$dest_string = $string_utils->dest_string($details);
		# if( ref($fn_ref) eq "CODE" ) {
			$ret = $fn_ref->($dest_string, @fn_arg);
		# }
	}
	
	return $ret;
}

sub spork {
	my( $dest, $fn_ref, @fn_arg ) = (shift, shift, @_);
	my( @childs, $dest_string, $wait, $ret );
	
	while( my( $name, $details ) = CORE::each( %{$dest} ) ) {
		$dest_string = $string_utils->dest_string($details);
		# if( ref($fn_ref) eq "CODE" ) {
			my $pid = fork();
			if( $pid ) { # parent
				push( @childs, $pid );
			} elsif( $pid == 0 ) { # child
				$ret = $fn_ref->($dest_string, @fn_arg);
				exit(0);
			} else {
				die Debug->error("Couldn’t fork: ".$!);
			}
			
		# }
	}

	foreach (@childs) {
		$wait = waitpid($_, 0);
		print "\tPID ".$wait." done\n\n";
	}
	
	return $ret;
}

# Do cleanups here - remove null items/format hash
sub get_monitor { my $monitor = { 
	$farm_config->{monitor}->{name} => $farm_config->{monitor} }; 
	bless $monitor; 
}
sub get_clients { my $clients = $farm_config->{clients}->{client}; bless $clients; }
sub get_servers { 
	my $servers = $farm_config->{servers}->{server}; 
	if( $servers->{name} ) { $servers = { 
		$servers->{name} => $servers }; 
	}
	else { $servers = $farm_config->{servers}->{server}; }
	bless $servers; 
}

return 1;