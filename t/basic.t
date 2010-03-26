#! /usr/bin/env perl

use Test::More;

use_ok 'Benchmark::Perl::Formance';
use_ok 'Benchmark::Perl::Formance::Cargo';
use_ok 'Benchmark';
use_ok 'Time::HiRes';
use_ok 'File::ShareDir';
use_ok 'Data::YAML::Writer';
use_ok 'Data::Structure::Util';
use_ok 'File::Copy::Recursive';


my $out = qx"PERLFORMANCE_TESTMODE_FAST=1 $^X -Ilib script/benchmark-perlformance -c --plugins=Fib";
like($out, qr/^results:/ms, "basic stuff - results");
like($out, qr/^perl_config:/ms, "basic stuff - perl_config");
like($out, qr/^perlformance_config:/ms, "basic stuff - perlformance_config");

done_testing();
