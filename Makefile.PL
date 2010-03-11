use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# general dependencies
requires 'forks';
requires 'Benchmark';
requires 'Time::HiRes';
requires 'Data::YAML::Writer';
requires 'Data::Structure::Util';

# SpamAssassin
requires 'DB_File';
requires 'Net::IP';               # really
requires 'Net::DNS';              # really
requires 'NetAddr::IP';           # really
requires 'HTML::Parser';          # really
requires 'Mail::SpamAssassin';
requires 'Perl::Formance::Cargo';

# OO
requires 'Moose' => '0.98';
requires 'Mouse';

# Rx
requires 'POSIX::Regex';
requires 're::engine::Lua';
requires 're::engine::LPEG';
requires 're::engine::Oniguruma';

# Shootout
requires 'Math::GMP';

install_script('script/benchmark-perlformance');
WriteAll;
