#!/usr/bin/perl
package TCPSock;

################# Use:
use strict;
use warnings;
use lib qw(Modules/);
use Debug;
use IO::Socket::INET;
use JSON;
use CTCTest;

################# My:
my $start_cmd = shift;
my ($socket, $local_sock, $client_sock, $peer_add, $sock_add, $peer_port);
my $local_data;
my $remote_data;
my $fdata;
my $local_port = '5978';
my $test = CTCTest->new();

################# Fn:


$| = 1;
if( $start_cmd and $start_cmd eq "stop" ) { exit(); }
elsif( $start_cmd and $start_cmd eq "start" ) { 
	# creating object interface of IO::Socket::INET modules which internally does
	# socket creation, binding and listening at the specified port address.
	$local_sock = IO::Socket::INET->new(
		LocalPort	=> $local_port,
		Proto 		=> 'tcp',
		Listen 		=> 5,
		Reuse 		=> 1,
		Blocking 	=> 1
	) or die Debug->error("Socket Creation: $!");
	Debug->success("TCPSock server now waiting for client connection on port ".$local_port);
	&start(); 
} else {
	Debug->error("TCPSock didn't start...");
}

################# Sub:
sub start {
	Debug->yell("Hello!");
	while(1) {
		# Wait for new client connection.
		$client_sock = $local_sock->accept();

		# get the host and port number of a newly connected client.
		if( $client_sock ) {

			$peer_add = $client_sock->peerhost();
			$sock_add = $client_sock->sockhost();
			$peer_port = $client_sock->peerport();
			Debug->info("Accepted new client connection from: ".$peer_add.", ".$peer_port);
			
			$client_sock->recv($remote_data, 1024);
			Debug->info("Received from Client:");
			
			if( $remote_data and decode_json($remote_data) ) {
				$fdata = decode_json($remote_data);
				Debug->dump("data from client", $fdata); 

				if( $fdata->{kill} ) { 
					Debug->action("kill server");
					Debug->warning("TCPSock.pm is closing socket...");
					sleep 5;
					exit(); 
				} else { 
					# Pass formatted data to Test and send client the response
					my $instructions = $test->status($fdata);
					# Debug->dump("TCPSock instructions", $instructions);

					&send($instructions) if $instructions;
				}
			
			} else { 
				Debug->error("bad json received (".$remote_data.")"); 
			}
			$remote_data = 0;
			$fdata = 0;
			# Debug->dump("reset remote_data", $remote_data);
		}
	}
}

sub send {
		my $wat = shift;
		# write operation on the newly accepted client.
		# Debug->dump("TCPSock send", $wat);

		$local_data = {
			instructions => $wat->{instructions},
			parameters => $wat->{parameters}
		};

		# we can also send the data through IO::Socket::INET module,
		$client_sock->send(encode_json($local_data));
		Debug->dump("sent data", $local_data);

		# read operation on the newly accepted client
		# $remote_data = <$client_sock>;
		# we can also read from socket through recv()  in IO::Socket::INET
		# $client_sock->recv($remote_data, 1024);
		# Debug->info("Received from Client:");
		# Debug->dump("data", decode_json($remote_data));
}

END { 
	if( $local_sock ) {
		sleep 1;
		$local_sock->close(); 
	}
}
		
return 1;