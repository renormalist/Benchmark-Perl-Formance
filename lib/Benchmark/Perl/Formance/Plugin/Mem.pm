package Benchmark::Perl::Formance::Plugin::Mem;

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
use Devel::Size 'total_size';

my @stuff;

sub allocate
{
        my ($options, $goal, $count) = @_;

        my $size = 0;
        my $t = timeit $count, sub {
                my @stuff;
                $#stuff = $goal;
        };
        return {
                Benchmark  => $t,
                goal       => $goal,
                count      => $count,
                total_size => $size,
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
                total_size => $size,
                allocate   => allocate ($options, $goal, $count),
                copy       => copy     ($options, $goal, $count),
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Mem - Stress memory operations (not yet implemented)

=cut

