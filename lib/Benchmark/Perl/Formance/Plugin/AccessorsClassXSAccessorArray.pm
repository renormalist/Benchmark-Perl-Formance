package Benchmark::Perl::Formance::Plugin::AccessorsClassXSAccessorArray;
# ABSTRACT: benchmark plugin - Compare OO'ish accessors

use strict;
use warnings;

our $VERSION = "0.001";

#############################################################
#                                                           #
# Benchmark Code ahead - Don't touch without strong reason! #
#                                                           #
#############################################################

our $goal;
our $count;

use Benchmark ':hireswallclock';

use Class::XSAccessor::Array
    constructor => 'new',
    accessors   => {"zomtec" => 42};

sub main
{
        my ($options) = @_;

        # ensure same values over all Accessors* plugins!
        $goal  = $options->{fastmode} ? 100_000 : 2_000_000;
        $count = 5;

        my $result;
        my $obj = __PACKAGE__->new;
        my $t_get   = timeit $count, sub { $result = $obj->zomtec()   for 1..$goal };
        my $t_set   = timeit $count, sub { $result = $obj->zomtec(23) for 1..$goal };
        return {
                get => {
                        Benchmark => $t_get,
                        result    => $result,
                        goal      => $goal,
                       },
                set => {
                        Benchmark => $t_set,
                        result    => $result,
                        goal      => $goal,
                       },
               };
}

1;
