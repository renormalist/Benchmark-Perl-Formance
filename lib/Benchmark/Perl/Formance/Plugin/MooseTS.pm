package Benchmark::Perl::Formance::Plugin::MooseTS;

use warnings;
use strict;

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);
use Benchmark::Perl::Formance::Cargo;

use vars qw($count $recurse);
$count   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;
$recurse = $ENV{PERLFORMANCE_TESTMODE_FAST} ? "" : "-r";

use Benchmark ':hireswallclock';

sub prepare {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 0 );
        my $srcdir = module_dir('Benchmark::Perl::Formance::Cargo')."/MooseTS";

        print STDERR "Prepare cargo Moose testsuite in $dstdir ...\n" if $options->{verbose} >= 3;

        dircopy($srcdir, $dstdir);

        my $prove = `which prove`;
        $prove =~ s/\s*$//;
        ($prove = $^X) =~ s!/perl([\d.]*)$!/prove$1! unless $prove;
        print STDERR "Use prove: $prove.\n" if $options->{verbose};

        die "Didn't find $prove" unless $prove && -x $prove;

        return ($dstdir, $prove, $recurse);
}

sub nonaggregated {
        my ($dstdir, $prove, $recurse, $options) = @_;

        my $cmd    = "cd $dstdir ; $^X $prove -Q $recurse '$dstdir/t'";
        print STDERR "$cmd\n" if $options->{verbose} >= 3;
        print STDERR "Run nonaggregated ...\n" if $options->{verbose} >= 3;

        my $t = timeit $count, sub { qx($cmd) };
        return {
                Benchmark  => $t,
                prove_path => $prove,
                count      => $count,
               };
}

sub aggregated {
        my ($dstdir, $prove, $recurse, $options) = @_;

        my $cmd    = "cd $dstdir ; $^X $prove -Q $recurse '$dstdir/aggregate.t'";
        print STDERR "$cmd\n" if $options->{verbose} >= 3;
        print STDERR "Run aggregated ...\n" if $options->{verbose} >= 3;

        my $t = timeit $count, sub { qx($cmd) };
        return {
                Benchmark  => $t,
                prove_path => $prove,
                count      => $count,
               };
}

sub main {
        my ($options) = @_;

        my ($dstdir, $prove, $recurse) = prepare($options);
        return nonaggregated($dstdir, $prove, $recurse, $options);
        # return {
        #         aggregated    => aggregated($dstdir, $prove, $recurse, $options),
        #         nonaggregated => nonaggregated($dstdir, $prove, $recurse, $options),
        #        };
}

1;

=pod

=head1 NAME

Benchmark::Perl::Formance::Plugin::MooseTS - Moose test suite as benchmark

=head1 ABOUT

This plugin runs a part of the Moose test suite.

=cut

