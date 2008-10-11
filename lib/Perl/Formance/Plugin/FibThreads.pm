package Perl::Formance::Plugin::FibThreads;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal $threadcount);
$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 27;
$threadcount = $ENV{PERLFORMANCE_THREADCOUNT} || 16;

use Time::HiRes 'gettimeofday';
use threads;

# BEGIN {
#         die "This is for Perl 5.8" if ($] < 5.008 or $] >= 5.009);
# }

sub fib
{
        my $n = shift;

        if ($n < 2) {
                return 1;
        } else {
                my $res;
                if (threads->list(threads::running) <= $threadcount-2) {
                        my $t1 = async { fib($n-1) };
                        my $t2 = async { fib($n-2) };
                        $res = $t1->join + $t2->join;
                } else {
                        $res = fib($n-1) + fib($n-2);
                }
                return $res;
        }
}

sub main
{
        my ($options) = @_;

        my $before = gettimeofday();
        my $ret    = fib($goal);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time  => sprintf("%0.4f", $diff),
                threadcount => $threadcount,
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress threads

=head1 CONFIGURATION

You can define how many threads should maximally be started. Default
is 16.

  $ export PERLFORMANCE_THREADCOUNT=64
  $ perl-formance --plugins=FibThreads

=cut
