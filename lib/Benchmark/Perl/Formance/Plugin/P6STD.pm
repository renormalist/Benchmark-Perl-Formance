package Benchmark::Perl::Formance::Plugin::P6STD;

use strict;
use warnings;

our $VERSION = "0.001";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

our $goal;
our $count;

use Benchmark ':all', ':hireswallclock';
use File::Temp qw(tempfile tempdir);
use File::ShareDir qw(dist_dir);
use File::Copy::Recursive qw(dircopy fcopy);
use Cwd;

sub prepare {
        my ($options) = @_;

        my $dstdir = tempdir( CLEANUP => 1 );
        my $cmd;

        my $srcdir = dist_dir('Benchmark-Perl-Formance-Cargo')."/P6STD";
        print STDERR "# Make viv in $dstdir ...\n" if $options->{verbose} >= 3;
        dircopy($srcdir, $dstdir);

        my $makeviv = { Benchmark => timeit(1,
                                            sub {
                                                 $cmd = "cd $dstdir ; make PERL=$^X 2>&1";
                                                 print STDERR "#   $cmd\n" if $options->{verbose} && $options->{verbose} >= 4;
                                                 my $output = qx"$cmd";
                                                 $output =~ s/^/\# /msg;
                                                 print STDERR $output if $options->{verbose} && $options->{verbose} >= 4;
                                                }),
                      };
        return $dstdir, $makeviv;
}

sub viv
{
        my ($workdir, $options) = @_;

        my $viv       = "$workdir/viv";
        my $perl6file = "$workdir/$goal";
        my $cmd       = "cd $workdir ; $^X -I. $viv $perl6file";

        print STDERR "# Running benchmark...\n" if $options->{verbose} && $options->{verbose} >= 3;
        print STDERR "#   $cmd\n"               if $options->{verbose} && $options->{verbose} >= 4;

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

        my $workdir;
        my $makeviv;
        my $viv;
        ($workdir, $makeviv ) = prepare($options);
        $viv = viv($workdir, $options);

        return {
                makeviv => $makeviv,
                viv     => $viv,
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::P6STD - Stress using Perl6/Perl5 tools around STD.pm

=cut
