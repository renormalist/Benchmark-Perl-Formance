package Benchmark::Perl::Formance::Plugin::Mem;

use strict;
use warnings;

our $VERSION = "0.002";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

our $goal;
our $count;

use Benchmark ':hireswallclock';
use Devel::Size 'total_size';

my @stuff;

sub allocate
{
        my ($options, $goal, $count) = @_;

        my $mygoal = ($options->{fastmode} ? 10 : 1) * $goal;
        my $t = timeit $count, sub {
                my @stuff1;
                $#stuff1 = $mygoal;
        };
        return {
                Benchmark  => $t,
                goal       => $mygoal,
                count      => $count,
               };
}

sub copy
{
        my ($options, $goal, $count) = @_;

        my $t = timeit $count, sub {
                my @copy = @stuff;
        };
        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
               };
}

sub main
{
        my ($options) = @_;

        $goal  = $options->{fastmode} ? 2_000_000 : 15_000_000;
        $count = $options->{fastmode} ? 5 : 20;

        $#stuff = $goal;
        my $size = total_size(\@stuff);

        return {
                total_size_bytes        => $size,
                copy                    => copy     ($options, $goal, $count),
                allocate                => allocate ($options, $goal, $count),
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Mem - Stress memory operations

=cut

