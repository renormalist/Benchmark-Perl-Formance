use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# general dependencies
requires 'forks';
requires 'Benchmark';
requires 'Time::HiRes';
requires 'File::ShareDir';
requires 'Data::YAML::Writer';
requires 'Data::Structure::Util';
requires 'File::Copy::Recursive';

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

# MooseTS
requires 'Test::Aggregate::Nested';
requires 'DateTime::Calendar::Mayan';
requires 'Regexp::Common';
requires 'Locale::US';
requires 'HTTP::Headers';
requires 'Params::Coerce';
requires 'URI';
requires 'Test::Output';
requires 'Module::Refresh';
requires 'DBM::Deep';
requires 'Declare::Constraints::Simple';

install_script('script/benchmark-perlformance');
WriteAll;
