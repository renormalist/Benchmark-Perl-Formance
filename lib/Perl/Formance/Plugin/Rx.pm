package Perl::Formance::Plugin::Rx;

# Regexes

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);

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
        foreach (1..1_000_000) {
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
        @count  = $rand_seq =~ /$search_seq(.*?)$search_seq/g;
        #print STDERR "found ".(scalar @count)." times.\n";
        $after  = gettimeofday();
        # ----------------------------------------------------
        $diff   = ($after - $before);
        $results{large_seq_time} = sprintf("%0.4f", $diff);
        # ----------------------------------------------------
}

sub pathological
{
        my ($options) = @_;

        # TODO, collection of known pathological stressful regexes
        #  //
        #  a*.*a* on large strings

        my $before;
        my $after;
        my %results = ();
        my $i;

        my $aaa = "a" x 1_000_000;
        my $bbb = "b" x 1_000_000;

        # ----------------------------------------------------
        $before = gettimeofday();
        for ($i=0; $i < 10_000; $i++) { $aaa =~ /a?a?a?aaa/g } # matches
        $after  = gettimeofday();
        $results{anaaa} = sprintf("%0.4f", $after - $before);
        # ----------------------------------------------------

        # ----------------------------------------------------
        $before = gettimeofday();
        for ($i=0; $i < 10_000; $i++) { $aaa =~ /a*.*a*/g } # matches
        $after  = gettimeofday();
        $results{a_stars} = sprintf("%0.4f", $after - $before);
        # ----------------------------------------------------

        # ----------------------------------------------------
        $before = gettimeofday();
        for ($i=0; $i < 10_000; $i++) { $bbb =~ /a*.*a*/g } # not matches
        $after  = gettimeofday();
        $results{not_a_stars} = sprintf("%0.4f", $after - $before);
        # ----------------------------------------------------

        # ----------------------------------------------------
        $before = gettimeofday();
        my @res = split (//, $aaa);
        $after  = gettimeofday();
        $results{split_empty} = sprintf("%0.4f", $after - $before);
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
