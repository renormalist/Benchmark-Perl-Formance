package Perl::Formance::Section::Fib;

# Fibonacci numbers

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);

sub fib
{
        my $n = shift;

        $n < 2
         ? 1
          : fib($n-1) + fib($n-2);
}

sub main
{
        my $before = gettimeofday();
        my $ret    = fib(40);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        print sprintf("Fib.plain time: %0.4f\n", $diff);
}

1;
