package Benchmark::Perl::Formance::Plugin::Shootout::revcomp;

# COMMAND LINE:
# /usr/bin/perl revcomp.perl-4.perl 0 < revcomp-input25000000.txt

# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
#
# Contributed by Andrew Rodland
# Benchmark::Perl::Formance plugin by Steffen Schwigon

use strict;

use Benchmark::Perl::Formance::Cargo;
use File::ShareDir qw(module_dir);
use Benchmark ':hireswallclock';

sub print_reverse {
  while (my $chunk = substr $_[0], -60, 60, '') {
          my $dummy = scalar reverse($chunk);
          print $dummy, "\n" if $ENV{PERLFORMANCE_SHOOTOUT_REVCOMP_PRINT};
  }
}

sub run
{
        my ($infile) = @_;

        my $data;

        my $srcdir = module_dir('Benchmark::Perl::Formance::Cargo')."/Shootout";
        my $srcfile = "$srcdir/$infile";
        open INFILE, "<", $srcfile or die "Cannot read $srcfile";

        while (<INFILE>) {
                if (/^>/) {
                        print_reverse $data;
                        print if $ENV{PERLFORMANCE_SHOOTOUT_REVCOMP_PRINT};
                } else {
                        chomp;
                        tr{wsatugcyrkmbdhvnATUGCYRKMBDHVN}
                          {WSTAACGRYMKVHDBNTAACGRYMKVHDBN};
                        $data .= $_;
                }
        }
        close INFILE;
        print_reverse $data;
}

sub main
{
        my ($options) = @_;

        my $goal   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? "fasta-1000.txt" : "fasta-1000000.txt";
        my $count  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;

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

Benchmark::Perl::Formance::Plugin::Shootout::revcomp - Language shootout revcomp plugin

=head1 ABOUT

This plugin does some runs the "revcomp" benchmark from the Language
Shootout.

=head1 CONFIGURATION

The output can be controlled via the environment variable:

   $ PERLFORMANCE_SHOOTOUT_REVCOMP_PRINT=1 perl-formance [...]

=cut
