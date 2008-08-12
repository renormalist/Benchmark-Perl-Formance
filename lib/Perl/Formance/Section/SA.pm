package Perl::Formance::Section::SA;

use warnings;
use strict;

use File::Temp qw(tempfile tempdir);
use File::Copy::Recursive qw(dircopy);
use File::ShareDir qw(module_dir);
use Time::HiRes qw(gettimeofday);

sub main {
        my $dstdir = tempdir( CLEANUP => 1 );
        my $srcdir = module_dir('Perl::Formance::Section::SA');

        dircopy($srcdir, $dstdir);
        my $cmd    = "time /usr/bin/env perl -T `which sa-learn` --ham -L --config-file=$dstdir/sa-learn.cfg --prefs-file=$dstdir/sa-learn.prefs --siteconfigpath=$dstdir --dbpath=$dstdir/db --no-sync  '$dstdir/easy_ham/*'";
        #print STDERR "$cmd\n";
        my $before = gettimeofday();
        my $ret    = system ($cmd);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        print sprintf("SA.learn time: %0.4f\n", $diff);
}

1;

__END__

time perl -T `which sa-learn` --ham -L --config-file=sa-learn.cfg --prefs-file sa-learn.prefs --dbpath db --no-sync  'easy_ham/*'
