package Perl::Formance::Plugin::MooseTS;

use warnings;
use strict;

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);
use Perl::Formance::Cargo;

use vars qw($count $recurse);
$count   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;
$recurse = $ENV{PERLFORMANCE_TESTMODE_FAST} ? "" : "-r";

use Benchmark ':hireswallclock';

sub main {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 0 );
        my $srcdir = module_dir('Perl::Formance::Cargo')."/MooseTS";

        print STDERR "Prepare cargo Moose testsuite in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);

        my $prove = `which prove`; chomp $prove;
        ($prove = $^X) =~ s!/perl([\d.]*)$!/prove$1! unless $prove;
        print STDERR "Use prove: $prove\n" if $options->{verbose};

        die "Didn't find $prove" unless $prove && -x $prove;

        my $cmd    = "cd $dstdir ; $^X $prove $recurse '$dstdir/t'";
        print STDERR "$cmd\n" if $options->{verbose} >= 3;

        my $ret;
        my $t = timeit $count, sub {
                                    print STDERR "Run ...\n" if $options->{verbose} >= 3;
                                    $ret = system ($cmd)
                                   };
        return {
                Benchmark  => $t,
                prove_path => $prove,
                count      => $count,
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
