use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# Specific dependencies
requires 'Pod::Help';
requires 'Benchmark';
requires 'Time::HiRes';
requires 'Data::YAML::Writer';
requires 'Perl::Formance::Cargo';

requires 'Mail::SpamAssassin';
requires 'forks';
requires 'Moose';
requires 'Mouse';

install_script('script/perl-formance');
WriteAll;
