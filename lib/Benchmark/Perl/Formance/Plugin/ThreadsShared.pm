package Benchmark::Perl::Formance::Plugin::ThreadsShared;

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
our $expect1;

use threads;
use threads::shared;

use Benchmark ':hireswallclock';
use Devel::Size 'total_size';
use Data::Dumper;

my @result : shared;
$#result = 1_000;

my $size = total_size(\@result);

sub run_thread_storm_shared
{
        my ($options) = @_;

        $result[-1] = 0;
        my @t;
        foreach (1..$threadcount) {
                push @t, async {
                        # print STDERR ".";
                        $result[-1] += $val;
                }
        }
        foreach (@t) {
                $_->join;
        }

        return $result[-1];
}

sub threadstorm
{
        my ($options) = @_;

        $goal        = $options->{fastmode} ? 3 : 25;
        $threadcount = $options->{fastmode} ? 5 : ($options->{D}{Threads_threadcount} || 100);
        $val         = 25;
        $expect1     = $threadcount * $val;

        my $ret1;
        my $t1 = timeit($goal, sub { $ret1 = run_thread_storm_shared  ($options) });

        return {
                Benchmark   => $t1,
                threadcount => $threadcount,
                total_size  => $size,
                result      => $ret1,
                expect      => $expect1,
                useforks => ($options->{useforks} || 0),
               };
}

sub main
{
        my ($options) = @_;

        return {
                threadstorm => threadstorm($options),
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::ThreadsShared - Stress shared threading

=head1 SYNOPSIS

Run it as any other plugin. You can define how many threads should
maximally be started. Default is 100.

  $ perl-formance --plugins=ThreadsShared -DThreads_threadcount=64

=head1 BUGS

Too naive. Really.

=cut
