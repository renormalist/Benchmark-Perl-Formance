package Benchmark::Perl::Formance::Plugin::SpamAssassin;

use strict;
use warnings;

our $VERSION = "0.002";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);
use Benchmark::Perl::Formance::Cargo;

our $count;
our $easy_ham;

use Benchmark ':hireswallclock';

sub main {
        my ($options) = @_;

        $count    = $options->{fastmode} ? 1 : 5;
        $easy_ham = $options->{fastmode} ? "easy_ham_subset" : "easy_ham";

        my $dstdir = tempdir( CLEANUP => 1 );
        my $srcdir = module_dir('Benchmark::Perl::Formance::Cargo')."/SpamAssassin";

        print STDERR "# Prepare cargo spam'n'ham files in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);

        (my $salearn     = $^X) =~ s!/perl[\d.]*$!/sa-learn!;
        my $salearncfg   = "$dstdir/sa-learn.cfg";
        my $salearnprefs = "$dstdir/sa-learn.prefs";

        print STDERR "# Use sa-learn: $salearn\n"      if $options->{verbose};
        print STDERR "#          cfg: $salearncfg\n"   if $options->{verbose};
        print STDERR "#        prefs: $salearnprefs\n" if $options->{verbose};

        return {
                salearn => {
                            failed       => "did not find executable sa-learn",
                            salearn_path => $salearn,
                           }
               } unless $salearn && -x $salearn;

        # spam variant:
        # my $cmd    = "time /usr/bin/env perl -T $salearn --spam -L --config-file=$salearncfg --prefs-file=$salearnprefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/spam_2/*'";
        # ham variant:
        chmod 0666, $salearncfg;
        if (open SALEARNCFG, ">", $salearncfg) {
                print SALEARNCFG "loadplugin Mail::SpamAssassin::Plugin::Bayes\n";
        } else {
                print STDERR "# could not write sa-learn.cfg: $salearncfg";
        }
        my $cmd = "$^X -T $salearn --ham -L --config-file=$salearncfg --prefs-file=$salearnprefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/$easy_ham/*'";
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

It uses the executable "sa-learn" that it by default searches in
the same path of your used perl executable ($^X).

=cut

__END__

time perl -T `which sa-learn` --ham -L --config-file=sa-learn.cfg --prefs-file sa-learn.prefs --dbpath db --no-sync  'easy_ham/*'
