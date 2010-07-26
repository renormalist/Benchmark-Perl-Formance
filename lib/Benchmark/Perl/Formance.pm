package Benchmark::Perl::Formance;

use 5.008;

use warnings;
use strict;

use Config;
use Exporter;
use Getopt::Long ":config", "no_ignore_case", "bundling";
use Data::Structure::Util "unbless";
use Data::YAML::Writer;
use Time::HiRes qw(gettimeofday);
use Devel::Platform::Info;
use List::Util "max";
use Data::DPath 'dpath', 'dpathi';
use File::Find;
use Storable "fd_retrieve", "store_fd";

our $VERSION = '0.20';

# comma separated list of default plugins
my $DEFAULT_PLUGINS = join ",", qw(DPath
                                   Fib
                                   FibOO
                                   Mem
                                   Prime
                                   Rx
                                   Shootout::fasta
                                   Shootout::regexdna
                                   Shootout::binarytrees
                                   Shootout::revcomp
                                   Shootout::nbody
                                   Shootout::spectralnorm
                                 );

my $ALL_PLUGINS = join ",", qw(DPath
                               Fib
                               FibMoose
                               FibMouse
                               FibMXDeclare
                               FibOO
                               Mem
                               MooseTS
                               P6STD
                               PerlCritic
                               Prime
                               RegexpCommonTS
                               Rx
                               RxCmp
                               Shootout::binarytrees
                               Shootout::fannkuch
                               Shootout::fasta
                               Shootout::knucleotide
                               Shootout::mandelbrot
                               Shootout::nbody
                               Shootout::pidigits
                               Shootout::regexdna
                               Shootout::revcomp
                               Shootout::spectralnorm
                               SpamAssassin
                               Threads
                               ThreadsShared
                             );

our $DEFAULT_INDENT          = 0;

our $PROC_RANDOMIZE_VA_SPACE = "/proc/sys/kernel/randomize_va_space";
our $PROC_DROP_CACHES        = "/proc/sys/vm/drop_caches";
our $SYS_CPB                 = "/sys/devices/system/cpu/cpu0/cpufreq/cpb";

my @run_plugins;

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

sub load_all_plugins
{
        my $path = __FILE__;
        $path =~ s,\.pmc?$,/Plugin,;

        my %all_plugins;
        finddepth ({ no_chdir => 1,
                     follow   => 1,
                     wanted   => sub { no strict 'refs';
                                       my $fullname = $File::Find::fullname;
                                       my $plugin   = $File::Find::name;
                                       $plugin      =~ s,^$path/*,,;
                                       $plugin      =~ s,/,::,;
                                       $plugin      =~ s,\.pmc?$,,;

                                       my $module = "Benchmark::Perl::Formance::Plugin::$plugin";
                                       # eval { require $fullname };
                                       eval "use $module"; ## no critic
                                       my $version = $@ ? "~" : ${$module."::VERSION"};
                                       $all_plugins{$plugin} = $version
                                         if -f $fullname && $fullname =~ /\.pmc?$/;
                               },
                   },
                   $path);
        return %all_plugins;
}

sub print_version
{
        my ($self) = @_;

        if ($self->{options}{verbose})
        {
                print "Benchmark::Perl::Formance version $VERSION\n";
                print "Plugins:\n";
                my %plugins = load_all_plugins;
                print "  (v$plugins{$_}) $_\n" foreach sort keys %plugins;
        }
        else
        {
                print $VERSION, "\n";
        }
}

sub usage
{
        print 'benchmark-perlformance - Frontend for Benchmark::Perl::Formance

Usage:

   $ benchmark-perlformance
   $ benchmark-perlformance --fastmode
   $ benchmark-perlformance --useforks
   $ benchmark-perlformance --plugins=SpamAssassin,RegexpCommonTS,RxCmp -v
   $ benchmark-perlformance -ccccc --indent=2
   $ benchmark-perlformance -q

If run directly it uses the perl in your PATH:

   $ /path/to/benchmark-perlformance

To use another perl start it via

   $ /other/path/to/bin/perl /path/to/benchmark-perlformance

For more details see

   man benchmark-perlformance
   perldoc Benchmark::Perl::Formance

';
}

sub set_proc
{
        my ($self, $file, $value) = @_;

        if (! -e $file) {
                print STDERR "# Could not find $file\n" if $self->{options}{verbose} >= 4;
                return undef;
        }
        if (not defined $value) {
                print STDERR "# No value given\n" if $self->{options}{verbose} >= 4;
                return undef;
        }

        my $orig_value;
        if (open (my $PROCFILE, "<", $file)) {
                local $/ = undef;
                $orig_value = <$PROCFILE>;
                close $PROCFILE;
        } else {
                print STDERR "# Could not read old value from $file\n" if $self->{options}{verbose} >= 4;
        }
        chomp $orig_value if defined $orig_value;

        if (open (my $PROCFILE, ">", $file)) {
                print $PROCFILE $value;
                close $PROCFILE;
        } else {
                print STDERR "# Could not write $value into $file\n" if $self->{options}{verbose} >= 4;
        }

        return $orig_value;
}

sub do_disk_sync {
        my ($self) = @_;
        system("sync");
}

# Try to stabilize a system.
# - Classical disk sync
# - Drop caches (http://linux-mm.org/Drop_Caches)
# - Disable address space randomization (ASLR) (https://wiki.ubuntu.com/Security/Features)
# - Disable "Core Performance Boost" (http://lkml.org/lkml/2010/3/22/333)
sub prepare_stable_system
{
        my ($self) = @_;

        my $orig_values;
        if ($^O eq "linux") {
                $orig_values->{aslr} = $self->set_proc ($PROC_RANDOMIZE_VA_SPACE, 0);
                $orig_values->{cpb}  = $self->set_proc ($SYS_CPB, 0);
                $self->do_disk_sync;
                $self->set_proc ($PROC_DROP_CACHES, 1);
        }
        return $orig_values;
}

sub restore_stable_system
{
        my ($self, $orig_values) = @_;
        if ($^O eq "linux") {
                $self->set_proc($PROC_RANDOMIZE_VA_SPACE, $orig_values->{aslr}) if defined $orig_values->{aslr};
                $self->set_proc($SYS_CPB,                 $orig_values->{cpb} ) if defined $orig_values->{cpb};
        }
}

sub run_plugin
{
        my ($self, $pluginname) = @_;

        no strict 'refs';       ## no critic
        print STDERR "# Run $pluginname...\n" if $self->{options}{verbose} >= 2;
        my $res;
        eval {
                use IO::Handle;
                pipe(PARENT_RDR, CHILD_WTR);
                CHILD_WTR->autoflush(1);
                my $pid = open(my $PLUGIN, "-|");
                if ($pid == 0) {
                        # run in child process
                        close PARENT_RDR;
                        eval "use Benchmark::Perl::Formance::Plugin::$pluginname"; ## no critic
                        if ($@) {
                                print STDERR "# Skip plugin '$pluginname'" if $self->{options}{verbose};
                                print STDERR ":$@"                if $self->{options}{verbose} >= 2;
                                print STDERR "\n"                 if $self->{options}{verbose};
                                exit 0;
                        }
                        my $orig_values = $self->prepare_stable_system;
                        $res = &{"Benchmark::Perl::Formance::Plugin::${pluginname}::main"}($self->{options});
                        $self->restore_stable_system($orig_values);
                        store_fd($res, \*CHILD_WTR);
                        close CHILD_WTR;
                        exit 0;
                }
                close CHILD_WTR;
                $res = fd_retrieve(\*PARENT_RDR);
                close PARENT_RDR;
                $res->{PLUGIN_VERSION} = ${"Benchmark::Perl::Formance::Plugin::${pluginname}::VERSION"};
        };
        if ($@) {
                $res = {
                        failed => "Plugin $pluginname failed",
                        ($self->{options}{verbose} > 3 ? ( error  => $@ ) : ()),
                       }
        }
        return $res;
}

sub run {
        my ($self) = @_;

        my $help           = 0;
        my $showconfig     = 0;
        my $outstyle       = "summary";
        my $platforminfo   = 0;
        my $verbose        = 0;
        my $version        = 0;
        my $fastmode       = 0;
        my $useforks       = 0;
        my $quiet          = 0;
        my $plugins        = $DEFAULT_PLUGINS;
        my $indent         = $DEFAULT_INDENT;
        my $tapdescription = "";
        my $D              = {};

        # get options
        my $ok = GetOptions (
                             "help|h"           => \$help,
                             "quiet|q"          => \$quiet,
                             "indent=i"         => \$indent,
                             "plugins=s"        => \$plugins,
                             "verbose|v+"       => \$verbose,
                             "outstyle=s"       => \$outstyle,
                             "fastmode"         => \$fastmode,
                             "version"          => \$version,
                             "useforks"         => \$useforks,
                             "showconfig|c+"    => \$showconfig,
                             "platforminfo|p"   => \$platforminfo,
                             "tapdescription=s" => \$tapdescription,
                             "D=s%"             => \$D,
                            );
        # fill options
        $self->{options} = {
                            help           => $help,
                            quiet          => $quiet,
                            verbose        => $verbose,
                            outstyle       => $outstyle,
                            fastmode       => $fastmode,
                            useforks       => $useforks,
                            showconfig     => $showconfig,
                            platforminfo   => $platforminfo,
                            plugins        => $plugins,
                            tapdescription => $tapdescription,
                            indent         => $indent,
                            D              => $D,
                           };

        do { $self->print_version; exit  0 } if $version;
        do { usage;                exit  0 } if $help;
        do { usage;                exit -1 } if not $ok;

        # use forks if requested
        if ($useforks) {
                eval "use forks"; ## no critic
                $useforks = 0 if $@;
                print STDERR "# use forks " . ($@ ? "failed" : "") . "\n" if $verbose;
        }

        # static list because dynamic require influences runtimes
        $plugins = $ALL_PLUGINS if $plugins eq "ALL";

        # run plugins
        my $before = gettimeofday();
        my %RESULTS;
        my @plugins = grep /\w/, split '\s*,\s*', $plugins;
        foreach (@plugins)
        {
                my @resultkeys = split(/::/, $_);
                my $res = $self->run_plugin($_);
                eval "\$RESULTS{results}{".join("}{", @resultkeys)."} = \$res"; ## no critic
        }
        my $after  = gettimeofday();
        $RESULTS{perlformance}{overall_runtime}   = $after - $before;
        $RESULTS{perlformance}{config}{fastmode}  = $fastmode;
        $RESULTS{perlformance}{config}{use_forks} = $useforks;

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

        # Perl Config
        if ($platforminfo)
        {
                $RESULTS{platform_info} = Devel::Platform::Info->new->get_info;
                delete $RESULTS{platform_info}{source}; # this currently breaks the simplified YAMLish
        }

        unbless (\%RESULTS);
        return \%RESULTS;
}

sub print_outstyle_yaml
{
        my ($self, $RESULTS) = @_;

        my $output = '';
        my $indent = $self->{options}{indent};
        my $yw = new Data::YAML::Writer;
        $yw->write($RESULTS, sub { $output .= shift()."\n" });
        $output =~ s/^/" "x$indent/emsg; # indent

        my $tapdescription = $self->{options}{tapdescription};
        $output = "ok $tapdescription\n".$output if $tapdescription;
        print $output;
}

sub find_interesting_result_paths
{
        my ($self, $RESULTS) = @_;

        my @all_keys = ();

        my $benchmarks = dpathi($RESULTS)->isearch("//Benchmark");

        while ($benchmarks->isnt_exhausted) {
                my @keys;
                my $benchmark = $benchmarks->value;
                my $ancestors = $benchmark->isearch ("/::ancestor");

                while ($ancestors->isnt_exhausted) {
                        my $key = $ancestors->value->first_point->{attrs}{key};
                        push @keys, $key if defined $key;
                }
                pop @keys;
                push @all_keys, join(".", reverse @keys);
        }
        return @all_keys;
}

sub print_outstyle_summary
{
        my ($self, $RESULTS) = @_;

        my @run_plugins = $self->find_interesting_result_paths($RESULTS);
        my $len = max map { length } @run_plugins;

        foreach (sort @run_plugins) {
                no strict 'refs'; ## no critic
                my @resultkeys = split(/\./);
                my ($res) = dpath("/results/".join("/", map { qq("$_") } @resultkeys)."/Benchmark/*[0]")->match($RESULTS);
                print sprintf("%-${len}s : %f\n", $_, ($res || 0));
        }
}

sub print_results
{
        my ($self, $RESULTS) = @_;
        return if $self->{options}{quiet};

        my $outstyle = $self->{options}{outstyle};
        $outstyle = "summary" unless $outstyle =~ qr/^(summary|yaml)$/;
        my $sub = "print_outstyle_$outstyle";

        $self->$sub($RESULTS);
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance - Perl Performance Benchmark Suite

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
it. Then use that mirror for all your installations of Benchmark::Perl::Formance.

On the other side this could be used to track the performance of your
installation over time by continuously upgrading from CPAN.

=head2 It is not scientific

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

    perldoc Benchmark::Perl::Formance

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

Copyright 2008-2010 Steffen Schwigon.

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.
