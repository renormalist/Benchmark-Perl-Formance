package Benchmark::Perl::Formance::Plugin::Threads;

# Create threads to evaluate Fibonacci numbers

use 5.008;
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
our $threadcount;
our $val;
our $expect;

use threads;
use threads::shared;

my $result : shared;

use Benchmark ':hireswallclock';
use Data::Dumper;

sub thread_storm
{
        my ($options) = @_;

        $result = 0;
        my @t;
        foreach (1..$threadcount) {
                push @t, async {
                        #print STDERR "." if $options->{verbose} >= 3;
                        $result += $val;
                }
        }
        foreach (@t) {
                $_->join;
        }

        #print STDERR "#  == $result\n" if $options->{verbose} >= 3;
        return $result;
}

sub main
{
        my ($options) = @_;

        $goal        = $options->{fastmode} ? 3 : 25;
        $threadcount = $options->{fastmode} ? 5 : ($options->{D}{Threads_threadcount} || 100);
        $val         = 25;
        $expect      = $threadcount * $val;

        my $ret;
        my $t = timeit($goal, sub { $ret = thread_storm($options) });

        return {
                Benchmark   => $t,
                threadcount => $threadcount,
                result      => $ret,
                expect      => $expect,
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Threads - Stress threading

=head1 SYNOPSIS

Run it as any other plugin.
You can define how many threads should maximally be started.
Default is 16.

  $ perl-formance --plugins=Threads -DThreads_threadcount=64

=head1 BUGS

Too naive. Really.

=cut
