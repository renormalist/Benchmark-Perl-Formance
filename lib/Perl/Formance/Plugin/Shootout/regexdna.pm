package Perl::Formance::Plugin::Shootout::regexdna;

# COMMAND LINE:
# /usr/bin/perl regexdna.perl-2.perl 0 < regexdna-input5000000.txt

# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
# contributed by Danny Sauer
# completely rewritten and
# cleaned up for speed and fun by Mirco Wahab
# improved STDIN read, regex clean up by Jake Berner
# More speed and multithreading by Andrew Rodland
# Perl::Formance plugin by Steffen Schwigon

use strict;
use warnings;

use Perl::Formance::Cargo;
use File::ShareDir qw(module_dir);
use Benchmark ':hireswallclock';

sub run
{
        my ($infile) = @_;

        my $srcdir = module_dir('Perl::Formance::Cargo')."/Shootout";
        my $srcfile = "$srcdir/$infile";
        open INFILE, "<", $srcfile or die "Cannot read $srcfile";

        my $l_file  = -s INFILE;
        my $content; read INFILE, $content, $l_file;
        # this is significantly faster than using <> in this case
        close INFILE;

        $content =~ s/^>.*//mg;
        $content =~ tr/\n//d;
        my $l_code  =  length $content;

        my @seq = ( 'agggtaaa|tttaccct',
                    '[cgt]gggtaaa|tttaccc[acg]',
                    'a[act]ggtaaa|tttacc[agt]t',
                    'ag[act]gtaaa|tttac[agt]ct',
                    'agg[act]taaa|ttta[agt]cct',
                    'aggg[acg]aaa|ttt[cgt]ccct',
                    'agggt[cgt]aa|tt[acg]accct',
                    'agggta[cgt]a|t[acg]taccct',
                    'agggtaa[cgt]|[acg]ttaccct' );

        my @procs;
        for my $s (@seq) {
                my $pat = qr/$s/;
                my $pid = open my $fh, '-|';
                defined $pid or die "Error creating process";
                unless ($pid) {
                        my $cnt = 0;
                        ++$cnt while $content =~ /$pat/gi;
                        print "$s $cnt\n";
                        exit 0;
                }
                push @procs, $fh;
        }

        for my $proc (@procs) {
                print
                <$proc>;
                close $proc;
        }

        my %iub = (         B => '(c|g|t)',  D => '(a|g|t)',
                            H => '(a|c|t)',   K => '(g|t)',    M => '(a|c)',
                            N => '(a|c|g|t)', R => '(a|g)',    S => '(c|g)',
                            V => '(a|c|g)',   W => '(a|t)',    Y => '(c|t)' );

        # We could cheat here by using $& in the subst and doing it inside a string
        # eval to "hide" the fact that we're using $& from the rest of the code... but
        # it's only worth 0.4 seconds on my machine.
        my $findiub = '(['.(join '', keys %iub).'])';

        $content =~ s/$findiub/$iub{$1}/g;

        return {
                length_file    => $l_file,
                length_code    => $l_code,
                length_content => length $content,
               };
}

sub main
{
        my ($options) = @_;

        my $goal   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? "fasta-10000.txt" : "fasta-1000000.txt";
        my $count  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;

        my $result;
        my $t = timeit $count, sub { $result = run($goal) };
        return {
                Benchmark     => $t,
                goal          => $goal,
                count         => $count,
                result        => $result,
               };
}

1;
