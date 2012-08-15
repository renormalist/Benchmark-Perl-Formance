package Benchmark::Perl::Formance::Plugin::Shootout::revcomp;

# COMMAND LINE:
# /usr/bin/perl revcomp.perl-4.perl 0 < revcomp-input25000000.txt

# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
#
# Contributed by Andrew Rodland
# Benchmark::Perl::Formance plugin by Steffen Schwigon

use strict;

our $VERSION = "0.002";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use File::ShareDir qw(dist_dir);
use Benchmark ':hireswallclock';

our $PRINT = 0;

sub print_reverse {
  no warnings 'uninitialized'; ## no critic
  while (my $chunk = substr $_[0], -60, 60, '') {
          my $dummy = scalar reverse($chunk);
          print $dummy, "\n" if $PRINT;
  }
}

sub run
{
        my ($infile) = @_;

        my $data;

        my $srcdir = dist_dir('Benchmark-Perl-Formance-Cargo')."/Shootout";
        my $srcfile = "$srcdir/$infile";
        open my $INFILE, "<", $srcfile or die "Cannot read $srcfile";

        while (<$INFILE>) {
                if (/^>/) {
                        print_reverse $data;
                        print if $PRINT;
                } else {
                        chomp;
                        tr{wsatugcyrkmbdhvnATUGCYRKMBDHVN}
                          {WSTAACGRYMKVHDBNTAACGRYMKVHDBN};
                        $data .= $_;
                }
        }
        close $INFILE;
        print_reverse $data;
}

sub main
{
        my ($options) = @_;

        $PRINT     = $options->{D}{Shootout_revcomp_print};
        my $goal   = $options->{fastmode} ? "fasta-1000000.txt" : "fasta-1000000.txt";
        my $count  = $options->{fastmode} ? 1 : 5;

        my $result;
        my $t = timeit $count, sub { $result = run($goal) };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
                result    => $result,
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Shootout::revcomp - Language shootout plugin: revcomp

=head1 ABOUT

This plugin does some runs the "revcomp" benchmark from the Language
Shootout.

=head1 CONFIGURATION

You can control whether to output the result in case you want to reuse
it:

   $ perl-formance --plugins=Shootout::revcomp \
                   -DShootout_revcomp_print=1

=cut
