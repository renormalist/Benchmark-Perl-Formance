package Benchmark::Perl::Formance::Plugin::Threads;

# Create threads to evaluate Fibonacci numbers

use 5.008;
use strict;
use warnings;

use vars qw($goal $threadcount $val $expect);

$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 3 : 25;
$threadcount = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 5 : ($ENV{PERLFORMANCE_THREADCOUNT} || 100);
$val         = 25;
$expect      = $threadcount * $val;

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

Benchmark::Perl::Formance::Plugin::FibThreads - Stress threads

=head1 CONFIGURATION

You can define how many threads should maximally be started. Default
is 16.

  $ export PERLFORMANCE_THREADCOUNT=64
  $ perl-formance --plugins=Threads

=head1 BUGS

Too naive. Really.

=cut
