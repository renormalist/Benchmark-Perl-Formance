package Benchmark::Perl::Formance::Plugin::Incubator;

use strict;
use warnings;

our $VERSION = "0.001";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';
use Devel::Size 'total_size';
use Math::MatrixReal;

sub matrix_multiply_fixsize
{
        my ($options) = @_;

        my $goal  = $options->{fastmode} ? 2_000_000 : 15_000_000;
        my $count = $options->{fastmode} ? 5 : 20;

        my $minigoal = int ($goal / 20_000);

        my @row;    $row[$_]    = 1        foreach 0..$minigoal-1;
        my @matrix; $matrix[$_] = [ @row ] foreach 0..$minigoal-1;

        my $size = total_size(\@matrix);

        my $m = Math::MatrixReal->new_from_rows(\@matrix);
        my $result;
        my ($rows,$columns) = $m->dim;
        my $t = timeit $count, sub {
                $result = $m->multiply($m);
        };
        return {
                Benchmark         => $t,
                goal              => $minigoal,
                count             => $count,
                matrix_size_bytes => $size,
                rows              => $rows,
                columns           => $columns,
               };
}

sub main
{
        my ($options) = @_;

        return {
                matrix_multiply_fixsize => matrix_multiply_fixsize ($options),
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Incubator - Incubator plugin for benchmark experiments

=head1 ABOUT

This is a B<free style> plugin where I collect ideas. Although it
might contain interesting code you should never rely on this plugin.

=cut

