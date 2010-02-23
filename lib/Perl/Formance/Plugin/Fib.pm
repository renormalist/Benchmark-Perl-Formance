package Perl::Formance::Plugin::Fib;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal);
$goal = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 35;

use Benchmark ':hireswallclock';

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

        my $result;
        my $t = timeit $count, sub { $result = fib $goal };
        return {
                Benchmark => $t,
                result    => $result,
                goal      => $goal,
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress recursion and function calls

=cut

