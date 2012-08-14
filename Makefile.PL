use inc::Module::Install;

# Define metadata
name           'Benchmark-Perl-Formance';
all_from       'lib/Benchmark/Perl/Formance.pm';

# general dependencies
requires 'Benchmark';
requires 'Time::HiRes';
requires 'Devel::Size' => '0.78';
requires 'File::ShareDir';
requires 'Data::YAML::Writer';
requires 'Data::Structure::Util';
requires 'File::Copy::Recursive';
requires 'Devel::Platform::Info';
requires 'Benchmark::Perl::Formance::Cargo' => '0.04';
requires 'Data::DPath' => '0.40';

test_requires 'Data::YAML::Reader';

recommends 'forks';

# SpamAssassin
recommends 'DB_File';
recommends 'Net::IP';               # really
recommends 'Net::DNS';              # really
recommends 'NetAddr::IP';           # really
recommends 'HTML::Parser';          # really
recommends 'Mail::SpamAssassin';

# OO
recommends 'MooseX::Declare';
recommends 'Moose' => '0.98';
recommends 'Mouse';

# RxCmp
recommends 'POSIX::Regex';
recommends 're::engine::Lua';
recommends 're::engine::LPEG';
recommends 're::engine::Plan9';
recommends 're::engine::Oniguruma';
recommends 're::engine::RE2';

# Shootout
recommends 'Math::GMP';

# Primes
recommends 'Crypt::Primes';
recommends 'Math::Primality';

# DPath
recommends 'Data::DPath';
recommends 'Clone';

# P6STD
recommends 'Text::Balanced';
recommends 'YAML::XS';
recommends 'Encode';

# PerlCritic
recommends 'Perl::Critic';

install_script('script/benchmark-perlformance');

repository 'git://github.com/renormalist/Benchmark-Perl-Formance.git';
bugtracker 'http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Benchmark-Perl-Formance';

WriteAll;
