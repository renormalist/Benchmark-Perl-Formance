use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# general dependencies
requires 'forks';
requires 'Pod::Help';
requires 'Benchmark';
requires 'Time::HiRes';
requires 'Data::YAML::Writer';

# SpamAssassin
requires 'Perl::Formance::Cargo';
requires 'Mail::SpamAssassin';
requires 'DB_File';

# OO
requires 'Moose';
requires 'Mouse';

# Rx
requires 'POSIX::Regex';
requires 're::engine::Lua';
requires 're::engine::LPEG';
requires 're::engine::Oniguruma';

install_script('script/perl-formance');
WriteAll;
