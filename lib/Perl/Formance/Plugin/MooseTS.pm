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
        print STDERR "Run ...\n" if $options->{verbose} >= 3;
        my $t = timeit $count, sub { $ret = system ($cmd) };
        return {
                Benchmark  => $t,
                prove_path => $prove,
                count      => $count,
               };
}

1;

=pod

=head1 NAME

Perl::Formance::Plugin::MooseTS - Moose test suite as benchmark

=head1 ABOUT

This plugin runs a part of the Moose test suite.

=cut

