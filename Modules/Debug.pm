#!/usr/bin/perl
package Debug;

use strict;
use warnings;
use Data::Dumper;
$Data::Dumper::Varname = "";
$Data::Dumper::Quotekeys = 0;
$Data::Dumper::Pair = ": ";
$Data::Dumper::Terse = 1;
use Term::ANSIColor qw(:constants);
$Term::ANSIColor::AUTORESET = 1;

my $message = "";
my ($package, $filename, $line) = caller;

sub error { 
	$message = $_[1];
	print BLACK ON_RED "\n ".$filename." ERROR:\n\t ".$message, RESET "\n"; 
}
sub warning {
	$message = $_[1];
	print BLACK ON_YELLOW "\n ".$filename." WARNING:\n\t ".$message, RESET "\n"; 
}
sub success {
	$message = $_[1];
	print BLACK ON_GREEN "\n SUCCESS: ".$message, RESET "\n";
}
sub info {
	$message = $_[1];
	print WHITE "\n INFO: ".$message, RESET "\n"; 
}
sub action {
	$message = $_[1];
	print BOLD CYAN "\n ".(caller(1))[3]." => ".$message, RESET "\n";
}
sub yell {
	$message = $_[1];
	print BOLD YELLOW "\n ".$package.":\n\t".$message, RESET "\n";
}
sub dump {
	my $label = $_[1];
	$message = $_[2];
	print BOLD MAGENTA "\n ".$label.": ".Dumper($message), RESET;
}
sub section {
	$message = $_[1];
	print "\n", BLACK ON_WHITE "\n ".$message, RESET;
}
sub prompt {
	$message = $_[1];
	my $input;
	print GREEN "\n ".$message, RESET;
	while( $input = <STDIN> ) {
		chomp( $input );
		last;
	}
	print $input;
	return $input;
}

return 1;