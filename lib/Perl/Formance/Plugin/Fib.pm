package Perl::Formance::Plugin::Fib;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal);
$goal = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 35;

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
        my ($options) = @_;

        my $before = gettimeofday();
        my $ret    = fib($goal);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time => sprintf("%0.4f", $diff),
                result     => $ret,
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress recursion and function calls

=cut

