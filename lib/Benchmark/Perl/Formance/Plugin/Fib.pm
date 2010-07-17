package Benchmark::Perl::Formance::Plugin::Fib;

# Fibonacci numbers

use strict;
use warnings;

our $VERSION = "0.001";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

our $goal;
our $count;

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

        # ensure same values over all Fib* plugins!
        $goal  = $options->{fastmode} ? 18 : 35;
        $count = 5;

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

Benchmark::Perl::Formance::Plugin::Fib - Stress recursion and function calls

=cut

