use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# Specific dependencies
requires      'Net::IP';
requires      'Net::DNS';
requires      'Pod::Help';
requires      'Time::HiRes';
requires      'Data::YAML::Writer';
requires      'Perl::Formance::Cargo';

recommends 'Mail::SpamAssassin';
recommends 'Regexp::Common';

recommends 'Moose';
recommends 'Mouse';

install_script('script/perl-formance');
WriteAll;
