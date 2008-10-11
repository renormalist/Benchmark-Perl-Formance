package Perl::Formance;

use 5.006001; # I don't really know yet, but that's the goal

use warnings;
use strict;

use Config;
use Exporter;
use Data::YAML::Writer;
use Getopt::Long qw(:config no_ignore_case bundling);

use vars qw($VERSION @ISA @EXPORT_OK);

$VERSION = '0.01';

push @ISA, 'Exporter'; @EXPORT_OK = qw(run print_results);

# comma separated list of default plugins
my $DEFAULT_PLUGINS = 'Rx,Fib,FibOO,FibThreads,SA';

# incrementaly interesting Perl Config keys
my %CONFIG_KEYS = (
                   0 => [],
                   1 => [
                         qw(perlpath
                            version
                            archname
                            archname64
                            osvers
                            usethreads
                            useithreads
                          )],
                   2 => [
                         qw(gccversion
                            gnulibc_version
                            usemymalloc
                            config_args
                            optimize
                          )],
                   3 => [qw(ccflags
                            cppflags
                            nm_so_opt
                          )],
                   4 => [qw(
                          )],
                   5 => [
                         sort keys %Config
                        ],
                  );

sub new {
        bless {}, shift;
}

# show POD from script/perl-formance
sub usage
{
        require Pod::Help;
        Pod::Help->help;
}

sub run {
        my ($self) = @_;

        my $help       = 0;
        my $showconfig = 0;
        my $verbose    = 0;
        my $plugins    = $DEFAULT_PLUGINS;
        my $options    = {};

        # get options
        my $ok         = GetOptions ("help|h"        => \$help,
                                     "verbose|v+"    => \$verbose,
                                     "showconfig|c+" => \$showconfig,
                                     "plugins=s"     => \$plugins);

        do { usage; exit  0 } if $help;
        do { usage; exit -1 } if not $ok;

        # fill options
        $options = {
                    help       => $help,
                    verbose    => $verbose,
                    showconfig => $showconfig,
                    plugins    => $plugins,
                   };

        # check plugins
        my @plugins = grep /\w/, split '\s*,\s*', $plugins;
        my @run_plugins = grep {
                eval "use Perl::Formance::Plugin::$_";
                if ($@) {
                        print "Skip plugin '$_'" if $verbose;
                        print ":$@"            if $verbose >= 2;
                        print "\n"             if $verbose;
                }
                not $@;
        } @plugins;

        # run plugins
        my %RESULTS;
        foreach (@run_plugins) {
                print STDERR "Run $_...\n" if $verbose;
                $RESULTS{results}{$_} = "Perl::Formance::Plugin::$_"->main();
        }

        # Perl Config
        if ($showconfig)
        {
                my @cfgkeys;
                push @cfgkeys, @{$CONFIG_KEYS{$_}} foreach 1..$showconfig;
                $RESULTS{perl_config} =
                {
                 map { $_ => $Config{$_} } sort @cfgkeys
                };
        }

        return \%RESULTS;
}

sub print_results
{
        my ($self, $RESULTS) = @_;

        my $yw = new Data::YAML::Writer;
        $yw->write($RESULTS, sub { print shift,"\n" });
}

=head1 NAME

Perl::Formance - Perl Performance Benchmark Suite

=head1 ABOUT

This benchmark suite tries to run some stressful programs and outputs
values that you can compare against other runs of this suite,
e.g. with other versions of Perl, modified compile parameter, or
another set of dependent libraries.


=head1 AUTHOR

Steffen Schwigon, C<< <ss5 at renormalist.net> >>

=head1 BUGS

=head2 No invariant dependencies

This distribution only contains the programs to run the tests and
according data. It uses a lot of libs from CPAN with all their
dependencies but it does not contain invariant versions of those used
dependency libs.

If total invariance is important to you, you are responsible to
provide that invariant environment by yourself. You could, for
instance, create a local CPAN mirror with CPAN::Mini and never upgrade
it. Then use that mirror for all your installations of Perl::Formance.

On the other side this could be used to track the performance of your
installation over time by continuously upgrading from CPAN.

=head2 It's not scientific

The benchmarks are basically just a collection of already existing
interesting things like large test suites found on CPAN or just
starting long running tasks that seem to stress perl features. It does
not really guarantee accuracy of only raw Perl features, i.e., it does
not care for underlying I/O speed and does not preallocate ressources
from the OS before using them, etc.

This is basically because I just wanted to start, even without
knowledge about "real" benchmark science.

Anyway, feel free to implement "real" benchmark ideas and send me
patches.


=head2 Bug reports

Please report any bugs or feature requests to C<bug-perl-formance at
rt.cpan.org>, or through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Formance>.  I
will be notified, and then you will automatically be notified of
progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perl::Formance

You can also look for information at:

=over 4

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Perl-Formance>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Perl-Formance>

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-Formance>

=item * Search CPAN

L<http://search.cpan.org/dist/Perl-Formance>

=back

=head1 ACKNOWLEDGEMENTS

=head1 COPYRIGHT & LICENSE

Copyright 2008 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1; # End of Perl::Formance
