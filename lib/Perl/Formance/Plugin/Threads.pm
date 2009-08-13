package Perl::Formance::Plugin::Threads;

# Create threads to evaluate Fibonacci numbers

use 5.008;

use warnings;
use strict;

use vars qw($goal $threadcount $val $expect);

$goal        = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 3 : 25;
$threadcount = $ENV{PERLFORMANCE_THREADCOUNT} || 100;
$val         = 25;
$expect      = $threadcount * $val;

use threads;
use threads::shared;

my $result : shared;

use Time::HiRes 'gettimeofday';

sub thread_storm
{
        $result = 0;
        my @t;
        foreach (1..$threadcount) {
                push @t, async {
                        print STDERR ".";
                        $result += $val;
                }
        }
        foreach (@t) {
                $_->join;
        }

        print STDERR " == $result\n";
        return $result;
}

sub main
{
        my ($options) = @_;

        my $ret;
        my $before = gettimeofday();
        do { $ret  = thread_storm() } for 1..$goal;
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time      => sprintf("%0.4f", $diff),
                threadcount     => $threadcount,
                result          => $ret,
                expect          => $expect,
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
