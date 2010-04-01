package Benchmark::Perl::Formance::Plugin::SpamAssassin;

use warnings;
use strict;

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);
use Benchmark::Perl::Formance::Cargo;

use vars qw($count $easy_ham);
$count    = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;
$easy_ham = $ENV{PERLFORMANCE_TESTMODE_FAST} ? "easy_ham_subset" : "easy_ham";

use Benchmark ':hireswallclock';

sub main {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 1 );
        my $srcdir = module_dir('Benchmark::Perl::Formance::Cargo')."/SpamAssassin";

        print STDERR "# Prepare cargo spam'n'ham files in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);


        my $salearn = `which sa-learn`; chomp $salearn;
        ($salearn = $^X) =~ s!/perl[\d.]*$!/sa-learn! unless $salearn;
        print STDERR "# Use sa-learn: $salearn\n" if $options->{verbose};

        die "Didn't find $salearn" unless $salearn && -x $salearn;

        # spam variant:
        # my $cmd    = "time /usr/bin/env perl -T $salearn --spam -L --config-file=$dstdir/sa-learn.cfg --prefs-file=$dstdir/sa-learn.prefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/spam_2/*'";
        # ham variant:
        my $cmd    = "$^X -T $salearn --ham -L --config-file=$dstdir/sa-learn.cfg --prefs-file=$dstdir/sa-learn.prefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/$easy_ham/*'";
        print STDERR "# $cmd\n" if $options->{verbose} >= 3;

        my $ret;
        my $t = timeit $count, sub {
                                    print STDERR "# Run...\n" if $options->{verbose} >= 3;
                                    $ret = qx($cmd); # catch stdout
                                   };
        return {
                salearn => {
                            Benchmark    => $t,
                            salearn_path => $salearn,
                            count        => $count,
                           }
               };
}

1;

=pod

=head1 NAME

Benchmark::Perl::Formance::Plugin::SpamAssassin - SpamAssassin Benchmarks

=head1 ABOUT

This plugin does some runs with SpamAssassin on the public corpus
provided taken from spamassassin.org.

=head1 CONFIGURATION

It uses the executable "sa-learn" that it by default searches in your
env or in the same path of your used perl executable ($^X).

=cut

__END__

time perl -T `which sa-learn` --ham -L --config-file=sa-learn.cfg --prefs-file sa-learn.prefs --dbpath db --no-sync  'easy_ham/*'
