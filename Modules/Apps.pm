#!/usr/bin/perl
package Apps;

################# Use:
use strict;
use warnings;
use Debug;
use Win32::GuiTest qw(
	FindWindowLike 
	GetWindowText 
	SetForegroundWindow 
	SendKeys 
	SendMouseMoveRel 
	SendMouseMoveAbs 
	PushChildButton 
	WMGetText
	SendMessage
	SetFocus
);
$Win32::GuiTest::debug = 0;
use Commands;

################# My:
my $commands = Commands->new();
my $app_ctrl = \&app_ctrl;
my $keys = \&keys;

################# Sub:
sub apps {
	my($dests, $app_class, $child_class, $key_commands) = (shift,shift,shift,shift);
	my $ret = $dests->each($app_ctrl, $app_class, $child_class, $key_commands);
	return $ret;
}

sub mce {Debug->yell("HERE WE ARE!!");}
sub wait {
	my $class = shift;
	my @handle;
	my $do = 1;
	while($do) {
		@handle = FindWindowLike(shift, shift, shift);
		if(!@handle) {$do = 0;}
		else {Debug->yell("Waiting on ".@handle); sleep 1;}
	}
	return 1;
}

sub app_ctrl {
	my($dest_string, $regx_class, $regx_child, $key_commands) = (shift,shift,shift,shift);
	my(@win_handle, @edit, $result, $focus);
		
	my $i = 0;
	while( $i le 3 ) {
		@win_handle = FindWindowLike( undef, undef, $regx_class ); 
	#								( $parent, $titleregex, $classregex, $childid, $maxlevel )
		$i += 1;
		sleep 0.5;
	}
    
	if( !@win_handle ){ # WTF Sometimes cannot be found... bad timing??
        die Debug->error("Cannot find window with title/caption/class ".$regx_class);
    } else {
        Debug->success("Window handle of application is ".$win_handle[0]);
	}
	
	if($regx_child ne "none") {
		$i = 0;
		while( $i le 3 ) {
			@edit = FindWindowLike( $win_handle[0], undef, $regx_child );
			$i += 1;
			sleep 0.5;
		}

		Debug->dump("edit arry", @edit);
		if( !@edit ){ # WTF Sometimes cannot be found... bad timing??
			die Debug->error("Cannot find window handle for Edit control");
		} else {
			Debug->success("Edit window handle is ".$edit[0]);
		}

		# $result = WMGetText( $edit[0] );
		# Debug->success("The result is ".$result.", which is as expected");

		sleep 1;
		# SetForegroundWindow( $win_handle[0] );
		$focus = $edit[0];
	} else {
		$focus = $win_handle[0];
	}
	SetFocus( $focus );
	
	# Ideal API ??
	# $media_center->($cmd);

	

	if(defined($key_commands)){
		$keys->($key_commands);
	}
	else {
		$keys->("^t");
	}
	
	# my $msg_id = 0xd;
    # my $hwnd = $win_handle[0]; #0x204ba;
    # my $buffer = " " x 100;
    # my $buf_ptr = pack( 'P', $buffer );
    # my $ptr = unpack( 'L!', $buf_ptr );
    # SendMessage( $hwnd, $msg_id, 100, $ptr ); 
    # print "The result from Calculator is $buffer\n";
}
sub keys { my $ret; foreach(@_) {sleep(1); Debug->action("Sending keystroke: ".$_); $ret = SendKeys($_);} return $ret; }

return 1;