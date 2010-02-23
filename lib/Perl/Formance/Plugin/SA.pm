package Perl::Formance::Plugin::SA;

use warnings;
use strict;

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);
use Perl::Formance::Cargo;

use vars qw($count);
$count = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;

use Benchmark ':hireswallclock';

sub main {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 0 );
        my $srcdir = module_dir('Perl::Formance::Cargo')."/SA";

        print STDERR "Prepare cargo spam'n'ham files in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);


        my $salearn = $ENV{PERLFORMANCE_SALEARN};
        ($salearn = $^X) =~ s!/perl[\d.]*$!/sa-learn! unless $salearn;
        print STDERR "Use sa-learn: $salearn\n" if $options->{verbose};

        die "Didn't find $salearn" unless $salearn && -x $salearn;

        # spam variant:
        # my $cmd    = "time /usr/bin/env perl -T $salearn --spam -L --config-file=$dstdir/sa-learn.cfg --prefs-file=$dstdir/sa-learn.prefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/spam_2/*'";
        # ham variant:
        my $cmd    = "$^X -T $salearn --ham -L --config-file=$dstdir/sa-learn.cfg --prefs-file=$dstdir/sa-learn.prefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/easy_ham/*'";
        print STDERR "$cmd\n" if $options->{verbose} >= 3;

        my $ret;
        my $t = timeit $count, sub {
                                    print STDERR "Run cmd...\n" if $options->{verbose} >= 3;
                                    $ret = system ($cmd)
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

Perl::Formance::Plugin::SA - SpamAssassin Benchmarks

=head1 ABOUT

This plugin does some runs with SpamAssassin on the public corpus
provided taken from spamassassin.org.

=head1 CONFIGURATION

It uses the executable "sa-learn", that it by default searches in the
same path of your used perl executable ($^X). In case you want to use
another "sa-learn" please set an environment variable
"PERLFORMANCE_SALEARN", e.g.:

  $ export PERLFORMANCE_SALEARN=/usr/local/bin/sa-learn
  $ perl-formance --plugins=SA

=cut

__END__

time perl -T `which sa-learn` --ham -L --config-file=sa-learn.cfg --prefs-file sa-learn.prefs --dbpath db --no-sync  'easy_ham/*'
