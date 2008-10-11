package Perl::Formance::Plugin::FibMoose;

# Fibonacci numbers

use warnings;
use strict;

use vars qw($goal);
$goal = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 35;

use Time::HiRes qw(gettimeofday);

use Moose;

sub fib
{
        my $self = shift;
        my $n    = shift;

        $n < 2
         ? 1
          : $self->fib($n-1) + $self->fib($n-2);
}

sub main
{
        my ($options) = @_;

        my $fib    = new Perl::Formance::Plugin::FibMoose;

        my $before = gettimeofday();
        my $ret    = $fib->fib($goal);
        my $after  = gettimeofday();
        my $diff   = ($after - $before);

        return {
                plain_time => sprintf("%0.4f", $diff)
               };
}

1;

__END__

=head1 NAME

Perl::Formance::Plugin::FibThreads - Stress recursion and method calls

=cut

