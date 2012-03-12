#!/usr/bin/perl

################# Use:
use strict;
use warnings;
use lib qw(../Modules/ Modules/);
use Debug;
use Win32::GuiTest qw(
	FindWindowLike 
	GetWindowText 
	SetForegroundWindow 
	SendKeys 
	PushChildButton 
	WMGetText
	SendMessage
	SetFocus
);
$Win32::GuiTest::debug = 0;

################# My:
my $cmds = @ARGV;
my $keys = \&keys;
&test();

################# Sub:
# Debug->yell("SHGSSGIUYSGUYGASIUTHHGSAFSADSBA!!!");
sub test {
	my (@win_handle, @edit, $result, $regx_class, $regx_child);
	$regx_class = "eHome Render";
	$regx_child = "eHome FlipEx";
	# $keys = "~{PAUSE 300}^D{PAUSE 300}{UP}{PAUSE 300}~";
	
	my $i = 0;
	while( $i le 3 ) {
		@win_handle = FindWindowLike( undef, undef, $regx_class ); 
	#								( $parent, $titleregex, $classregex, $childid, $maxlevel )
		$i += 1;
		Debug->info($i);
		sleep 0.5;
	}
    
	if( !@win_handle ){ # WTF Sometimes cannot be found... bad timing??
        die Debug->error("Cannot find window with title/caption/class ".$regx_class);
    } else {
        Debug->yell("Window handle of application is ".$win_handle[0]);
	}
	
	# SetForegroundWindow( $win_handle[0] );
	# PushChildButton( $win_handle[0], 132 );
	# sleep 0.3;
    # SendKeys( "{+}6=" );
	
	# my $edit_ctrl_id = 2687920; #Edit window, 000 Hex
	$i = 0;
	while( $i le 3 ) {
		@edit = FindWindowLike( $win_handle[0], undef, $regx_child );
		$i += 1;
		Debug->info($i);
		sleep 0.5;
	}

	Debug->dump("edit arry", @edit);
    if( !@edit ){ # WTF Sometimes cannot be found... bad timing??
        die Debug->error("Cannot find window handle for Edit control");
    } else {
        Debug->yell("Edit window handle is ".$edit[0]);
    }
    
	$result = WMGetText( $edit[0] );
	Debug->success("The result is ".$result.", which is as expected");
	
	sleep 1;
	SetForegroundWindow( $win_handle[0] );
	SetFocus( $edit[0] );
	
	# Ideal API ??
	# $media_center->($cmd);

	if(defined($cmds)){$keys->($cmds);}
	else {
	$keys->("{DOWN}");
	$keys->("~");
	$keys->("{DOWN}");
	$keys->("{DOWN}");
	$keys->("~");
	$keys->("{DOWN}");
	$keys->("{DOWN}");
	$keys->("~");
	$keys->("~");
	
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
sub keys { foreach(@_) {sleep(1); my $ret = SendKeys($_);} return $ret; }