use strict;
use warnings;
use Module::Build;

my $builder = Module::Build->new(
    module_name         => 'Perl::Formance',
    license             => 'perl',
    dist_author         => 'Steffen Schwigon <ss5@renormalist.net>',
    dist_version_from   => 'lib/Perl/Formance.pm',
    build_requires => {
        'Test::More' => 0,
    },
    requires => {
                 'Net::IP'            => 0, # for SpamAssassin
                 'Net::DNS'           => 0, # for SpamAssassin
                 'Mail::SpamAssassin' => 0,
                 'Regexp::Common'     => 0,
                 'forks'              => 0,
                },
    add_to_cleanup      => [ 'Perl-Formance-*' ],
);

$builder->create_build_script();
