#! /usr/bin/env perl

use Test::More;

diag "Sample run. May take some seconds...";
my $out = qx"$^X -Ilib script/benchmark-perlformance --fastmode";
ok($out, "survived sample run");
diag $out;

done_testing();
