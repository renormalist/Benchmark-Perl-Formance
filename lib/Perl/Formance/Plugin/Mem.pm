package Perl::Formance::Plugin::Mem;

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

=pod

=head1 NAME

Perl::Formance::Plugin::Skeleton - An example plugin

=head1 ABOUT

You can create your own plugins by just creating a module in the
namespace C<Perl::Formance::Plugin::*> which simply has to provide a

 package Perl::Formance::Plugin::HotStuff;
 
 sub main {
     my ($options) = @_;
     
     # do something
     
     return { result_key1 => $value1,
              result_key2 => $value2,
            }
  }

To use it call the frontend tool and provide your pluginname via
--plugins:

  $ perl-formance --plugins=HotStuff

If your module should be a default part of the Perl::Formance suite,
then patch the C<$DEFAULT_PLUGINS> in lib/Perl/Formance.pm.

=cut

