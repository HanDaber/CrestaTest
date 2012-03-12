#!/usr/bin/perl

use strict;
use warnings;
use lib qw(../Modules/);
use IO::Socket::INET;
use Debug;
use JSON;
use Client;

my ($local_sock, $client_sock);
my ($local_data, $remote_data);
my $monitor_ip = shift;
my $remote_cmds = \@ARGV;
my $local_port = '5978';
my $client = Client->new();

Debug->dump("remote cmds", $remote_cmds);

# creating object interface of IO::Socket::INET modules which internally creates
# socket, binds and connects to the TCP server running on the specific port.
$local_sock = IO::Socket::INET->new(
	PeerHost => $monitor_ip,
	PeerPort => $local_port,
	Proto => 'tcp'
) or die Debug->error("Socket Creation: $!");
# Debug->success("TCP Connection!");
	
if( $remote_cmds and @{$remote_cmds}[0] =~ m/kill/i ) {
	Debug->warning("Sending server the kill command ".@{$remote_cmds}[0]);
	$local_sock->send(encode_json({kill=>1}));
} else {
	# write on the socket to server.
	my $status = $remote_cmds;
	
	$local_data = {
		monitor			=> $local_sock->peerhost(),
		local_client	=> $local_sock->sockhost()
	};
	
############################################### MOVE THIS ################################
	Debug->dump("tcp_client status", $status);
	if( @{$status}[0] eq "player" ) {
		system("../exe.bat");
	}
	# for my $i ( 0 .. @{$remote_cmds} ) {
		# $local_data->{status}->{$i} = $_[$i];
	# }
	
	# we can also send the data through IO::Socket::INET module,
	$local_sock->send(encode_json($local_data));
	Debug->info("Sent local data to server...");
	# Debug->dump("data", $local_data);

	# read the socket data sent by server.
	# $remote_data = <$local_sock>;
	# we can also read from socket through recv()  in IO::Socket::INET
	$local_sock->recv($remote_data, 1024);
	Debug->info("Received from Server...");
	Debug->dump("data", decode_json($remote_data));
	
	my $response = decode_json($remote_data);
	
	if( $response ) { 
		Debug->info("Client is processing response...");
		$client->process($response);
	} else { 
		Debug->error("Server response is no bueno: ".$response); 
	}
}

sleep (1);
$local_sock->close();