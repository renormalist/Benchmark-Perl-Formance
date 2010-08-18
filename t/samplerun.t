#! /usr/bin/env perl

use Test::More;

my $out = qx"$^X -Ilib script/benchmark-perlformance --fastmode";
ok($out, "survived sample run");
diag $out;

done_testing();
