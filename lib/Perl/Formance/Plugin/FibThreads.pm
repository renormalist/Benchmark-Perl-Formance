package Perl::Formance::Plugin::FibThreads;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal $threadcount);
$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 25;
$threadcount = $ENV{PERLFORMANCE_THREADCOUNT} || 16;

use Time::HiRes 'gettimeofday';
use 5.008;
BEGIN { eval "use forks" if  $ENV{PERLFORMANCE_USE_FORKS} }
use threads;

sub fib
{
        my $n = shift; sleep 1;

        if ($n < 2) {
                return 1;
        } else {
                my $res;
                if (threads->list(threads::running) <= $threadcount-2) {
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

        my $before = gettimeofday();
        my $ret    = fib($goal);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time  => sprintf("%0.4f", $diff),
                threadcount => $threadcount,
                result      => $ret,
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

You can use the C<forks> drop-in replacement for threads when setting
this variable to true:

  $ export PERLFORMANCE_USE_FORKS=1

=cut
