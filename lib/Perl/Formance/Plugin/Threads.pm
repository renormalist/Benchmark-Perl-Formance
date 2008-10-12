package Perl::Formance::Plugin::Threads;

# Create threads to evaluate Fibonacci numbers

use 5.008;

use warnings;
use strict;

use vars qw($goal $threadcount);

$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 25;
$threadcount = $ENV{PERLFORMANCE_THREADCOUNT} || 16;


use threads;
use threads::shared;

my $counted_threads : shared;

use Time::HiRes 'gettimeofday';

sub fib
{
        my $n = shift;

        if ($n < 2) {
                return 1;
        } else {
                my $res;
                if (threads->list(threads::running) <= $threadcount-2) {
                        $counted_threads++;
                        my $t1 = async { fib($n-1) };
                        my $t2 = async { fib($n-2) };
                        return $t1->join + $t2->join;
                } else {
                        return fib($n-1) + fib($n-2);
                }
        }
}

sub main
{
        my ($options) = @_;

        my $ret;
        my $before = gettimeofday();
        do { $ret  = fib($goal) } for 1..20;
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time      => sprintf("%0.4f", $diff),
                threadcount     => $threadcount,
                result          => $ret,
                counted_threads => $counted_threads,
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
  $ perl-formance --plugins=Threads

=head1 BUGS

Too naive. Really.

=cut
