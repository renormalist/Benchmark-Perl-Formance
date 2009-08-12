use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# Specific dependencies
requires 'Net::IP';
requires 'Net::DNS';
requires 'Pod::Help';
requires 'Time::HiRes';
requires 'Data::YAML::Writer';
requires 'Perl::Formance::Cargo';

requires 'Mail::SpamAssassin';
requires 'Regexp::Common';
requires 'forks';
requires 'Moose';
requires 'Mouse';

install_script('script/perl-formance');
WriteAll;
