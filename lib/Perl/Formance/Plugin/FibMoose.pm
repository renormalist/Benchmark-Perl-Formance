package Perl::Formance::Plugin::FibMoose;

# Fibonacci numbers

use strict;
use warnings;

use vars qw($goal $count);
$goal  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 18 : 35; # same over Fib, FibOO, FibMoose, FibMouse
$count = 5;

use Benchmark ':hireswallclock';

use Moose;

sub fib
{
        my $self = shift;
        my $n    = shift;

        $n < 2
            ? 1
            : $self->fib($n-1) + $self->fib($n-2);
}

sub main
{
        my ($options) = @_;

        my $result;
        my $fib = __PACKAGE__->new;
        my $t   = timeit $count, sub { $result = $fib->fib($goal) };
        return {
                Benchmark => $t,
                result    => $result,
                goal      => $goal,
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress recursion and method calls

=cut

