package Perl::Formance::Plugin::RxCmp;

# Compare different Regexes engines plugins (Perl 5.10+)

use 5.010; # [sic - pluggable regex engines]
use strict;
use warnings;

use Benchmark ':hireswallclock';
use Data::Dumper;

use vars qw($goal $count $length $n $re $string);
$goal   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 5 : 29; # probably 28 or more
$count  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1 : 5;

$n      = $goal;
$re     = ("a?" x $n) . ("a" x $n);
$string = "a" x $n;

sub native
{
        my ($options) = @_;

        my $result;
        my $reg = qr/$re/o;
        my $t = timeit $count, sub { $result = $string =~ $reg };
        return {
                Benchmark             => $t,
                goal                  => $goal,
                count                 => $count,
                result                => $result,
                # string                => $string,
                # re                    => $re,
                used_qr_or_precompile => 1,
               };
}

sub POSIX
{
        my ($options) = @_;

        my $reg;
        eval '
                use POSIX::Regex qw(:all);
                $reg = POSIX::Regex->new($re, REG_EXTENDED);
        ';
        if ($@) {
                print STDERR $@ if $options->{verbose} > 2;
                return { failed => "use failed" };
        }


        my $result;
        my $t = timeit $count, sub { $result = $reg->match($string) };
        return {
                Benchmark             => $t,
                goal                  => $goal,
                count                 => $count,
                result                => $result,
                # string                => $string,
                # re                    => $re,
                used_qr_or_precompile => 1,
               };
}

sub LPeg
{
        my ($options) = @_;

        # LPEG regexes seemingly don't work the same way as usual regexes
        # therefore the pattern below does not match.
        # TODO: Find a equivalent pattern.
        eval "use re::engine::LPEG";
        if ($@) {
                print STDERR $@ if $options->{verbose} > 2;
                return { failed => "use failed" };
        }

        return { "not yet implemented" => 'missing comparable equivalent regex' };

        my $result;
        my $re_local = ("'a'?" x $n) . ("'a'" x $n);
        #my $reg      = qr/$re_local/; # using that $reg later segfaults
        my $t = timeit $count, sub { $result = $string =~ /$re_local/ };
        return {
                Benchmark             => $t,
                goal                  => $goal,
                count                 => $count,
                result                => $result,
                # string                => $string,
                # re                    => $re_local,
                used_qr_or_precompile => 0,
               };
}

sub Lua
{
        my ($options) = @_;

        # LPEG regexes seemingly don't work the same way as usual regexes
        # therefore the pattern below does not match.
        # TODO: Find a equivalent pattern.
        # return { "not yet implemented" => 'not yet implemented' };

        eval "use re::engine::Lua";
        if ($@) {
                print STDERR $@ if $options->{verbose} > 2;
                return { failed => "use failed" };
        }

        my $result;
        #my $reg      = qr/$re/; # using that $reg later segfaults, unfortunately that makes
        my $t = timeit $count, sub { $result = $string =~ /$re/ };
        return {
                Benchmark             => $t,
                goal                  => $goal,
                count                 => $count,
                result                => $result,
                # string                => $string,
                # re                    => $re,
                used_qr_or_precompile => 0,
               };
}

sub PCRE
{
        my ($options) = @_;

        eval "use re::engine::PCRE";
        if ($@) {
                print STDERR $@ if $options->{verbose} > 2;
                return { failed => "use failed" };
        }

        my $result;
        my $reg = qr/$re/o;
        my $t = timeit $count, sub { $result = $string =~ $reg };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
                result    => $result,
                # string    => $string,
                # re        => $re_local,
                used_qr_or_precompile => 1,
               };
}

sub Oniguruma
{
        my ($options) = @_;

        eval "use re::engine::Oniguruma";
        if ($@) {
                print STDERR $@ if $options->{verbose} > 2;
                return { failed => "use failed" };
        }

        my $result;
        my $reg = qr/$re/o;
        my $t = timeit $count, sub { $result = $string =~ $reg };
        return {
                Benchmark             => $t,
                goal                  => $goal,
                count                 => $count,
                result                => $result,
                # string                => $string,
                # re                    => $re,
                used_qr_or_precompile => 1,
               };
}

sub regexes
{
        my ($options) = @_;

        # http://swtch.com/~rsc/regexp/regexp1.html

        my %results = ();

        no strict "refs";
        for my $subtest (qw( native POSIX Lua )) { #  LPeg PCRE Oniguruma
                print STDERR " - $subtest...\n" if $options->{verbose} > 2;
                $results{$subtest} = $subtest->($options);
        }
        # ----------------------------------------------------

        return \%results;
}

sub main
{
        my ($options) = @_;

        return regexes($options);
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::RxCmp - Compare different Regexes engines plugins (Perl 5.10+)

=head1 ABOUT

Perl 5.10 allows to plug in other Regular expression engines. So we
compare different Regexes engines with pathological regular
expressions. Inspired by and examples taken from
L<http://swtch.com/~rsc/regexp/regexp1.html>.

=cut

