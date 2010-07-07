package Benchmark::Perl::Formance::Plugin::P6STD;

use strict;
use warnings;

our $goal;
our $count;

use Benchmark ':all', ':hireswallclock';
use File::Temp qw(tempfile tempdir);
use File::ShareDir qw(module_dir);
use File::Copy::Recursive qw(dircopy);
use Cwd;

sub prepare {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 1 );
        my $srcdir = module_dir('Benchmark::Perl::Formance::Plugin::P6STD');
        print STDERR "# Prepare files in $dstdir ...\n" if $options->{verbose} >= 3;
        dircopy($srcdir, $dstdir);
        return $dstdir;
}

sub gimme5
{
        my ($workdir, $options) = @_;

        my $gimme5    = "gimme5";
        my $perl6file = "$goal";
        my $cmd       = "cd $workdir ; $^X -I. $gimme5 $perl6file";

        print STDERR "# Running benchmark....\n" if $options->{verbose} && $options->{verbose} > 2;
        print STDERR "#   $cmd\n"                if $options->{verbose} && $options->{verbose} > 3;

        my $t;
        $t = timeit ($count, sub { qx"$cmd" });
        return {
                Benchmark => $t,
                goal      => $goal,
               };
}

sub viv
{
        my ($workdir, $options) = @_;

        my $viv       = "$workdir/viv";
        my $perl6file = "$workdir/$goal";
        my $cmd       = "cd $workdir ; $^X -I. $viv $perl6file";

        print STDERR "# Running benchmark...\n" if $options->{verbose} && $options->{verbose} > 2;
        print STDERR "#   $cmd\n"               if $options->{verbose} && $options->{verbose} > 3;

        my $t;
        $t = timeit ($count, sub { qx"$cmd" });
        return {
                Benchmark => $t,
                goal      => $goal,
               };
}

sub main {
        my ($options) = @_;

        $goal  = $options->{fastmode} ? "hello.p6" : "STD.pm6";
        $count = $options->{fastmode} ? 1          : 5;

        my $workdir = prepare($options);
        return {
                gimme5 => gimme5($workdir, $options),
                viv    => viv($workdir, $options),
               };
}
1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::DPath - Use DPath to stress lookup, traversing and copying data structures

=cut
