package Perl::Formance::Plugin::Shootout::revcomp;

COMMAND LINE:
/usr/bin/perl revcomp.perl-4.perl 0 < revcomp-input25000000.txt

# The Computer Language Benchmarks Game
# http://shootout.alioth.debian.org/
#
# Contributed by Andrew Rodland
# Perl::Formance plugin by Steffen Schwigon

use strict;

sub print_reverse {
  while (my $chunk = substr $_[0], -60, 60, '') {
    print scalar reverse($chunk), "\n";
  }
}

my $data;

while (<STDIN>) {
  if (/^>/) {
    print_reverse $data;
    print;
  } else {
    chomp;
    tr{wsatugcyrkmbdhvnATUGCYRKMBDHVN}
      {WSTAACGRYMKVHDBNTAACGRYMKVHDBN};
    $data .= $_;
  }
}
print_reverse $data;

1;
