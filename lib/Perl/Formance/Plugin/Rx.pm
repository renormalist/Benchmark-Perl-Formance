package Perl::Formance::Plugin::Rx;

# Regexes

use warnings;
use strict;

use Time::HiRes qw(gettimeofday);
use Benchmark;

use vars qw($goal);
$goal = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 5 : 20; # probably 28 or more

sub pathological
{
        my ($options) = @_;

        # http://swtch.com/~rsc/regexp/regexp1.html

        my $before;
        my $after;
        my $count;
        my $n;
        my $re;
        my $string;
        my %results = ();

        $before = gettimeofday();
        $n      = $goal;
        $re     = ("a?" x $n) . ("a" x $n);
        $string = "a" x $n;
        $string =~ /$re/;
        $after  = gettimeofday();

        $results{pathology} = sprintf("%0.4f", $after - $before);

        # ----------------------------------------------------

        # { "abcdefg",	"abcdefg"	},
        # { "(a|b)*a",	"ababababab"	},
        # { "(a|b)*a",	"aaaaaaaaba"	},
        # { "(a|b)*a",	"aaaaaabac"	},
        # { "a(b|c)*d",	"abccbcccd"	},
        # { "a(b|c)*d",	"abccbcccde"	},
        # { "a(b|c)*d",	"abcccccccc"	},
        # { "a(b|c)*d",	"abcd"		},

        # ----------------------------------------------------

        $re     = '(.*) (.*) (.*) (.*) (.*)';
        $string = ("a" x 10_000_000) . " ";
        $string = $string x 5;
        chop $string;

        print STDERR "3...\n";
        $before = gettimeofday();
        my @r = $string =~ /$re/;

        print STDERR "res: ", ~~@r, "\n";
        $after  = gettimeofday();

        print STDERR "4...\n";
        $results{fieldsplit} = sprintf("%0.4f", $after - $before);
        # ----------------------------------------------------

        return \%results;
}

sub main
{
        my ($options) = @_;

        return {
                pathological => pathological($options),
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress regular expressions

=cut

