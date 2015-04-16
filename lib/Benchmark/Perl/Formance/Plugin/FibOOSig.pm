package Benchmark::Perl::Formance::Plugin::FibOOSig;

# Fibonacci numbers, using methods with signatures (Perl 5.20+)

BEGIN {
        if ($] < 5.020) {
                die "Perl 5.020+ required for subs with signatures.\n";
        }
}

use strict;
use warnings;
no warnings 'experimental';
use experimental 'signatures';

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

sub new {
        bless {}, shift;
}

sub fib ($self, $n)
{
        $n < 2
            ? 1
            : $self->fib($n-1) + $self->fib($n-2);
}

sub main
{
        my ($options) = @_;

        # ensure same values over all Fib* plugins!
        $goal  = $options->{fastmode} ? 20 : 35;
        $count = 5;

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

Benchmark::Perl::Formance::Plugin::FibOOSig - Stress recursion and method calls (plain OO with function signatures)

=cut
