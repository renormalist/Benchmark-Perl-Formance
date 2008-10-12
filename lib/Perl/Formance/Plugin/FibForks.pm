package Perl::Formance::Plugin::FibForks;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal $threadcount);
$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 25;
$threadcount = $ENV{PERLFORMANCE_FORKCOUNT} || 16;

use Time::HiRes 'gettimeofday';
use 5.008;
use forks;

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

Perl::Formance::Plugin::FibForks - Stress forks. Use the
C<forks.pm> drop in replacement for C<threads.pm>.

=head1 CONFIGURATION

You can define how many forks should maximally be started. Default is
16.

  $ export PERLFORMANCE_FORKCOUNT=64
  $ perl-formance --plugins=FibForks

=cut
