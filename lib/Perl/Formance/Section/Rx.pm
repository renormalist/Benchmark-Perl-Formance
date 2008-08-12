package Perl::Formance::Section::Rx;

# Regexes

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);

# find sequence in large sequence
sub large_seq
{
        my $before;
        my $after;
        my $diff;
        my $count;

        srand(17); # same seed, same sequence everytime
        # ----------------------------------------------------
        $before = gettimeofday();
        my $search_sequence = '';
        foreach (1..10_000) {
                my $c = chr 64 + int rand 27;
                $c = $c eq '@' ? ' ' : $c;
                $search_sequence .= $c;
        }
        my $rand_sequence = '';
        foreach (1..100_000_000) {
                my $c = chr(65 + int (rand 62));
                $c = $c eq '\\' ? 'X' : $c;
                $rand_sequence .= $c;
        }
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        print sprintf("Rx.silly_str_copy time: %0.4f\n", $diff);
        # ----------------------------------------------------

        # place what we search at end
        $rand_sequence = $search_sequence.$rand_sequence.$search_sequence.$rand_sequence.$search_sequence;


        # ----------------------------------------------------
        $before = gettimeofday();
        $count  = $rand_sequence =~ /$search_sequence.*?$search_sequence/g;
        print STDERR "found $count times.\n";
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        print sprintf("Rx.large_seq time: %0.4f\n", $diff);
        # ----------------------------------------------------
}

sub main
{
        large_seq();
}

1;
