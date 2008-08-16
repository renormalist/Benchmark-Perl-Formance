use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# Specific dependencies
requires       'Net::IP';
requires       'Net::DNS';
requires       'Pod::Help';
requires       'Time::HiRes';
requires       'Regexp::Common';
requires       'Data::YAML::Writer';
requires       'Mail::SpamAssassin';
requires       'Perl::Formance::Cargo';

install_script('script/perl-formance');
WriteAll;
