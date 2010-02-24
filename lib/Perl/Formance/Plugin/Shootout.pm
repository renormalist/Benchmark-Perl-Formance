package Perl::Formance::Plugin::Shootout;

use strict;
use warnings;

use Benchmark ':hireswallclock';
use Data::Dumper;

our $VERSION = '0.01';

sub pidigits
{
        my ($options) = @_;

        my $goal   = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 100 : 20_000;
        my $count  = $ENV{PERLFORMANCE_TESTMODE_FAST} ? 1   : 5;

        my $result;
        my $t = timeit $count, sub { $result = Perl::Formance::Plugin::Shootout::pidigits::main($goal) };
        return {
                Benchmark => $t,
                goal      => $goal,
                count     => $count,
                #result    => $result, # tooooo long
                result    => substr($result, 0, $goal <= 10 ? $goal : 10),
               };
}

sub shootout
{
        my ($options) = @_;

        no strict "refs";

        my %results = ();
        for my $subtest (qw( pidigits  ))
        {
                print STDERR " - $subtest...\n" if $options->{verbose} > 2;
                eval "use Perl::Formance::Plugin::Shootout::$subtest";
                $results{$subtest} = $subtest->($options);
        }
        return \%results;
}

sub main
{
        my ($options) = @_;

        return shootout($options);
}

1; # End of Perl::Formance::Plugin::Shootout


__END__

=head1 NAME

Perl::Formance::Plugin::Shootout - Perl::Formance plugin covering Alioth Shootout code

=head1 SYNOPSIS

Use it as Perl::Formance plugin:

  $ perl-formance --plugins=Shootout

=head1 BUGS

Please report any bugs or feature requests to
C<bug-perl-formance-plugin-languageshootout at rt.cpan.org>, or
through the web interface at
L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Perl-Formance-Plugin-LanguageShootout>.
I will be notified, and then you'll automatically be notified of
progress on your bug as I make changes.


=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Perl::Formance::Plugin::LanguageShootout


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Perl-Formance-Plugin-LanguageShootout>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Perl-Formance-Plugin-LanguageShootout>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Perl-Formance-Plugin-LanguageShootout>

=item * Search CPAN

L<http://search.cpan.org/dist/Perl-Formance-Plugin-LanguageShootout/>

=back


=head1 AUTHOR

The plugin wrapper for Perl::Formance benchmark suite is written by

  Steffen Schwigon c<< <ss5 at renormalist.net> >>

The benchmark code is taken from L<http://shootout.alioth.debian.org>,
written by their respective authors under the following license:

=head1 COPYRIGHT & LICENSE

 This is a specific instance of the Open Source Initiative (OSI) BSD
 license template.

 Revised BSD license

 Copyright © 2004-2010 Brent Fulgham

 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:

    * Redistributions of source code must retain the above copyright
      notice, this list of conditions and the following disclaimer.

    * Redistributions in binary form must reproduce the above
      copyright notice, this list of conditions and the following
      disclaimer in the documentation and/or other materials provided
      with the distribution.

    * Neither the name of "The Computer Language Benchmarks Game" nor
      the name of "The Computer Language Shootout Benchmarks" nor the
      names of its contributors may be used to endorse or promote
      products derived from this software without specific prior
      written permission.

 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
 "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
 LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
 A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
 OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
 SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
 LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
