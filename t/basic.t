#! /usr/bin/env perl

use Test::More;
use YAML::XS;
use Data::Dumper;

use_ok 'Benchmark::Perl::Formance';
use_ok 'Benchmark::Perl::Formance::Cargo';
use_ok 'Benchmark';
use_ok 'Time::HiRes';
use_ok 'File::ShareDir';
use_ok 'Data::YAML::Writer';
use_ok 'Data::Structure::Util';
use_ok 'File::Copy::Recursive';

my $out = qx"PERLFORMANCE_TESTMODE_FAST=1 $^X -Ilib script/benchmark-perlformance -c --plugins=Fib";
#diag Dumper($out);
my $outdata = Load($out);

ok(defined $outdata->{results}, "basic stuff - results");
ok(defined $outdata->{perl_config}, "basic stuff - perl_config");
ok(defined $outdata->{perlformance}, "basic stuff - perlformance meta info");
ok(defined $outdata->{perlformance}{config}, "basic stuff - performance config");
ok(defined $outdata->{perlformance}{overall_runtime}, "basic stuff - performance runtime");

done_testing();
