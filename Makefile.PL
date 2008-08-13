use inc::Module::Install;

# Define metadata
name           'Perl-Formance';
all_from       'lib/Perl/Formance.pm';

# Specific dependencies
requires       'Net::IP';
requires       'Net::DNS';
requires       'Mail::SpamAssassin';
requires       'Regexp::Common';
requires       'Perl::Formance::Cargo';

install_script('perl_formance');
WriteAll;
