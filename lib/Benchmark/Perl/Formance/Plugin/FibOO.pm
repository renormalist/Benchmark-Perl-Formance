package Benchmark::Perl::Formance::Plugin::FibOO;

# Fibonacci numbers

use strict;
use warnings;

use vars qw($goal $count);
$goal  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 18 : 35; # same over Fib, FibOO, FibMoose, FibMouse
$count = 5;

use Benchmark ':hireswallclock';

sub new {
        bless {}, shift;
}

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

Benchmark::Perl::Formance::Plugin::FibOO - Stress recursion and method calls (plain OO)

=cut

