package Benchmark::Perl::Formance::Plugin::RxMicro;
# ABSTRACT: benchmark plugin - Rx - Stress regular expressions

# Regexes

use strict;
use warnings;

our $VERSION = "0.001";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
# The code in here has compile-time and run-time effects!   #
#                                                           #
#############################################################

use Benchmark ':hireswallclock';
use Data::Dumper;

our $goal;
our $count;
our $length;

sub rxmicro
{
        my ($options) = @_;

        my %results = ();

        # ----------------------------------------------------

        {
                # how quickly a pre-compiled regex is accessed:

                my $subtest = "precompile-access";
                my $r = qr/\d+/;
                my $t = timeit $count, sub { "1234" =~ $r for 1..50000*$goal };
                $results{$subtest} = {
                                      Benchmark => $t,
                                      goal      => $goal,
                                      count     => $count,
                                     };
        }

        # ----------------------------------------------------

        {
                # how quickly run-time regexes are compiled

                my $subtest = "runtime-compile";
                my $r ='\d+';
                my $t = timeit $count, sub { "1234" =~ $r for 1..100000*$goal };
                $results{$subtest} = {
                                      Benchmark => $t,
                                      goal      => $goal,
                                      count     => $count,
                                     };
        }

        # ----------------------------------------------------

        {
                # run-time regexes are compiled but defeating the caching

                my $subtest = "runtime-compile-nocache";
                my $r ='\d+';
                my $t = timeit $count, sub { "1234" =~ /$r$_/ for 1..10000*$goal };
                $results{$subtest} = {
                                      Benchmark => $t,
                                      goal      => $goal,
                                      count     => $count,
                                     };
        }

        # ----------------------------------------------------

        {
                # run-time code-blocks

                my $subtest = "code-runtime";
                my $counter;
                my $code = '(?{$counter++})';
                use re 'eval';

                my $t = timeit $count, sub { $counter = 0; "1234" =~ /\d+$code/ for 1..20000*$goal };
                $results{$subtest} = {
                                      Benchmark => $t,
                                      goal      => $goal,
                                      count     => $count,
                                      counter   => $counter,
                                     };
        }

        # ----------------------------------------------------

        # This block here must come *LAST* - it *HEAVILY* influences others!
        {
                # literal code-blocks

                my $subtest = "code-literal";
                my $t = timeit $count, sub { "1234" =~ /\d+(?{$count++})/ for 1..40000*$goal };
                $results{$subtest} = {
                                      Benchmark => $t,
                                      goal      => $goal,
                                      count     => $count,
                                     };
        }

        # ----------------------------------------------------

        return \%results;
}

sub main
{
        my ($options) = @_;

        $goal   = $options->{fastmode} ? 20 : 29;
        $length = $options->{fastmode} ? 1_000_000 : 10_000_000;
        $count  = 5;

        return rxmicro($options);
}

1;
