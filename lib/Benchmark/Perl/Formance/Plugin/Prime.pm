package Benchmark::Perl::Formance::Plugin::Prime;

# Prime numbers

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

sub math_primality
{
        my ($options) = @_;

        eval "use Math::Primality 'next_prime'";
        if ($@) {
                print STDERR "# ".$@ if $options->{verbose} > 2;
                return { failed => "use Math::Primality failed" };
        }

        my $t;
        my $result;
        my $numgoal = 10 ** $goal;
        $t = timeit $count, sub { $result = next_prime($numgoal) };
        return {
                Benchmark => $t,
                result    => "$result", # stringify from blessed
                goal      => $goal,
                numgoal   => $numgoal,
               };
}

sub crypt_primes
{
        my ($options) = @_;

        eval "use Crypt::Primes 'maurer'";
        if ($@) {
                print STDERR "# ".$@ if $options->{verbose} > 2;
                return { failed => "use Crypt::Primes failed" };
        }

        my $t;
        my $result;
        my $bitgoal = int($goal * 3.36); # bitness in about same size order as int length in math_primality
        print STDERR "bitgoal: $bitgoal\n";
        $t = timeit $count, sub { $result = maurer(Size => $bitgoal) };
        return {
                Benchmark => $t,
                result    => "$result", # stringify from blessed
                goal      => $goal,
                bitgoal   => $bitgoal,
               };
}

sub main {
        my ($options) = @_;

        $goal  = $options->{fastmode} ? 15 : 22;
        $count = 5;

        return {
                math_primality => math_primality($options),
                crypt_primes   => crypt_primes($options),
               };
}
1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Prime - Stress math libs (Math::GMPz)

=cut

