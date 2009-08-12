package Perl::Formance::Plugin::Threads;

# Create threads to evaluate Fibonacci numbers

use 5.008;

use warnings;
use strict;

use vars qw($goal $threadcount);

$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 10 : 25;
$threadcount = $ENV{PERLFORMANCE_THREADCOUNT} || 100;

use forks;
use threads;
use threads::shared;

my $result : shared;

use Time::HiRes 'gettimeofday';

sub thread_storm
{
        my $val    = 25;
        my $expect = $threadcount * $val;
        my $result = 0;
        my $t;
        foreach (1..$threadcount) {
                $t = async {
                        print STDERR ".";
                        $result += $val
                };
                $t->join;
        }
        print STDERR "\n";
        return $result;
}

sub main
{
        my ($options) = @_;

        my $ret;
        my $before = gettimeofday();
        do { $ret  = thread_storm() } for 1..20;
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time      => sprintf("%0.4f", $diff),
                threadcount     => $threadcount,
                result          => $ret,
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
