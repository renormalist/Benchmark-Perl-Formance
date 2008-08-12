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
        my @count;

        srand(17); # same seed, same sequence everytime
        # ----------------------------------------------------
        $before = gettimeofday();
        my $search_seq = '';
        foreach (1..100_000) {
                my $c = chr 64 + int rand 27;
                $c = $c eq '@' ? ' ' : $c;
                $search_seq .= $c;
        }
        my $rand_seq = '';
        foreach (1..1_000_000) {
                my $c = chr(65 + int (rand 62));
                $c = $c eq '\\' ? 'X' : $c;
                $rand_seq .= $c;
        }
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        print sprintf("Rx.silly_str_copy time: %0.4f\n", $diff);
        # ----------------------------------------------------

        # place what we search at begin, middle and end
        $rand_seq
         =
          $search_seq
           .$rand_seq
            .$search_seq
             .$rand_seq
              .$search_seq;

        # ----------------------------------------------------
        $before = gettimeofday();
        @count  = $rand_seq =~ /$search_seq(.*?)$search_seq/g;
        print STDERR "found ".(scalar @count)." times.\n";
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
