package Benchmark::Perl::Formance::Plugin::Fib;

# Fibonacci numbers

use strict;
use warnings;

use vars qw($goal $count);
$goal  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 18 : 35; # same over Fib, FibOO, FibMoose, FibMouse
$count = 5;

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

Benchmark::Perl::Formance::Plugin::FibThreads - Stress recursion and function calls

=cut

