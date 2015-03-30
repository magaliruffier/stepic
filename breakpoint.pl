#!/usr/local/ensembl/bin/perl -w



=head1 NAME

  find_unique.pl


=head1 DESCRIPTION

  This script, run on a sequence file, returns the list of n-kmers


=head1 OPTIONS

        -file        name of the sequence file

=head1 EXAMPLE

perl find_kmer.pl -file sequence.fa
=cut



use strict;
use Getopt::Long;

my $file;


#my @list = (3, 4, 5, -12, -8, -7, -6, 1, 2, 10, 9, -11, 13, 14);
my @list = (1, -3, -6, -5, 2, -4);
my $length = scalar(@list);


my ($list, $hash_list);
my $breakpoint = 0;
if ($list[0] != 1) {
  $breakpoint++;
}
for (my $k = 1; $k < $length; $k++) {
  if ($list[$k] > 0) {
    if ($list[$k] != $list[$k-1] + 1) {
      $breakpoint++;
    }
  } elsif ($list[$k] < 0) {
    if ($list[$k] != $list[$k-1] + 1) {
      $breakpoint++;
    }
  }
#print "Compared " . $list[$k] . " with " . $list[$k-1] . " and got $breakpoint\n";
}
if ($list[$length-1] != $length) {
  $breakpoint++;
}

print "Total breakpoint $breakpoint\n";

