package Benchmark::Perl::Formance::Plugin::Incubator;

use strict;
use warnings;

our $VERSION = "0.002";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';

sub incubator
{
        my ($options) = @_;

        my $count = 1;

        my $t = timeit $count, sub { sleep 2 };
        return {
                Benchmark => $t,
                goal      => $count,
               };
}

sub main
{
        my ($options) = @_;

        return {
                incubator => incubator ($options),
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

