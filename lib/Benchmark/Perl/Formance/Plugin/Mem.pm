package Benchmark::Perl::Formance::Plugin::Mem;

use warnings;
use strict;

use vars qw($goal $count);
$goal  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 15 : 35;
$count = 5;

use Benchmark ':hireswallclock';

sub lots_of_malloc
{
        my $n = shift;
        sleep 1;
}

sub main {
        my ($options) = @_;

        my $t = timeit $count, sub { lots_of_malloc($goal) };
        return {
                Benchmark => $t,
                count     => $count,
                not_yet => "implemented, stay tuned...",
               };
}

1;

__END__

=head1 NAME

Benchmark::Perl::Formance::Plugin::Mem - Stress memory operations (not yet implemented)

=cut

