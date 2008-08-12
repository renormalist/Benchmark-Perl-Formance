#!perl -T

use Test::More tests => 1;

BEGIN {
	use_ok( 'Perl::Formance' );
}

diag( "Testing Perl::Formance $Perl::Formance::VERSION, Perl $], $^X" );
