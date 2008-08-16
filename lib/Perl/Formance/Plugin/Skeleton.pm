package Perl::Formance::Plugin::Skeleton;

# Regexp::Common - deprecated, not a good regex performance benchmark

use warnings;
use strict;

sub main {
        my ($options) = @_;

        # $options->{help}
        # $options->{verbose}
        # $options->{plugins}
        # $options->{showconfig}

        my $before   = gettimeofday();

        sleep 1; # your benchmark runs here

        my $after    = gettimeofday();
        my $duration = ($after - $before);

        return {
                skeleton_time => sprintf("%0.4f", $duration)
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

If your module should be part of the official Perl::Formance benchmark
suite, then patch the default list in Perl/Formance.pm.

=cut

