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
use File::ShareDir qw(dist_dir);
use Time::HiRes qw(gettimeofday);

our $count;
our $easy_ham;

use Benchmark ':hireswallclock';

sub main {
        my ($options) = @_;

        my $srcdir; eval { $srcdir = dist_dir('Benchmark-Perl-Formance-Cargo')."/SpamAssassin" };
        if ($@) {
                return { salearn => { failed => "no Benchmark-Perl-Formance-Cargo" } }
        }

        (my $salearn = $^X) =~ s!/perl[\d.]*$!/sa-learn!;
        if (not $salearn && -x $salearn) {
                print STDERR "# did not find executable $salearn\n" if $options->{verbose} >= 2;
                return { salearn => { failed => "did not find executable sa-learn", salearn_path => $salearn } };
        }

        $count     = $options->{fastmode} ? 1 : 5;
        my @passes = $options->{fastmode} ? (
                                             { metric => "ham",
                                               type   => "ham",
                                               subdir => "easy_ham_subset",
                                             },
                                            ) :
                                             (
                                              { metric => "ham",
                                                type   => "ham",
                                                subdir => "easy_ham",
                                              },
                                              { metric => "ham2",
                                                type   => "ham",
                                                subdir => "easy_ham_2",
                                              },
                                              { metric => "spam",
                                                type   => "spam",
                                                subdir => "spam",
                                              },
                                              { metric => "spam2",
                                                type   => "spam",
                                                subdir => "spam_2",
                                              },
                                             );

        # sa-learn
        my %results;
        for my $pass (@passes) {
                my @output;
                my $cmd       = "$^X -T $salearn --$pass->{type} -L --no-sync '$srcdir/$pass->{subdir}' 2>&1";
                print STDERR "\n# $cmd\n" if $options->{verbose} >= 4;
                my $t         = timeit $count, sub { @output = map { chomp; $_ } qx($cmd) };
                my $maxerr    = ($#output < 10) ? $#output : 10;
                print STDERR join("\n# ", "", @output[0..$maxerr]) if $options->{verbose} >= 4;

                $results{salearn}{$pass->{metric}} = {
                                                      Benchmark    => [@$t],
                                                      salearn_path => $salearn,
                                                      count        => $count,
                                                     };
        }
        return \%results;
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
