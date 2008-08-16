package Perl::Formance::Plugin::Rx;

# Regexes

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);
use Benchmark;

# find sequence in large sequence
sub large_seq
{
        my ($options) = @_;

        my $before;
        my $after;
        my $diff;
        my @count;
        my %results = ();

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
        foreach (1..10_000_000) {
                my $c = chr(65 + int (rand 62));
                $c = $c eq '\\' ? 'X' : $c;
                $rand_seq .= $c;
        }
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        $results{silly_str_copy_time} = sprintf("%0.4f", $diff);
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
        @count  = $rand_seq =~ /($search_seq(.*?)$search_seq)/g;
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        $results{large_seq_time} = sprintf("%0.4f", $diff);
        $results{large_seq_time_count} = @count;
        # ----------------------------------------------------

        return \%results;
}

sub pathological
{
        my ($options) = @_;

        # TODO, collection of known pathological stressful regexes
        #  //
        #  a*.*a* on large strings

        my $before;
        my $after;
        my $count;
        my %results = ();
        my $i;

        my $aaa;
        my $bbb;


        # ----------------------------------------------------
        $aaa = "a" x 1_000_000; # 10_000_000
        $before = gettimeofday();
        for ($i=0; $i < 1; $i++) { # 100
                $count = scalar @{[ $aaa =~ /(a?a?a?aaa)/g ]};
        }
        $after  = gettimeofday();
        $results{_01_anaaa} = sprintf("%0.4f", $after - $before);
        $results{_01_anaaa_count} = $count;
        # ----------------------------------------------------

        # ----------------------------------------------------
        $aaa = "a" x 5_000_000; # 10_000_000
        print STDERR "1...\n";
        $before = gettimeofday();
        $count  = scalar @{[ $aaa =~ /(a*?a*?a*?)/g]};

        print STDERR "2...\n";
        $after  = gettimeofday();
        $results{_02_a_stars} = sprintf("%0.4f", $after - $before);
        $results{_02_a_stars_count} = $count;
        # ----------------------------------------------------

        # ----------------------------------------------------
        $bbb = "b" x 1_000_000; # 10_000_000
        $before = gettimeofday();
        #for ($i=0; $i < 10_000; $i++) {
                $count = scalar @{[ $bbb =~ /(a*.*a*)/g ]};
        #}
        $after  = gettimeofday();
        $results{_03_not_a_stars} = sprintf("%0.4f", $after - $before);
        $results{_03_not_a_stars_count} = $count;
        # ----------------------------------------------------

        # ----------------------------------------------------
#         $before = gettimeofday();
#         $count  = scalar @{[ split (//, $aaa) ]};
#         $after  = gettimeofday();
#         $results{split_empty} = sprintf("%0.4f", $after - $before);
#         $results{split_empty_count} = $count;
        # ----------------------------------------------------

        return \%results;
}

sub main
{
        my ($options) = @_;

        return {
                large_seq    => large_seq($options),
                pathological => pathological($options),
               };
}

1;
