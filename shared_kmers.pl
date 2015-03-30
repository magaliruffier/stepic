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
&GetOptions('file:s'      => \$file ) ;
open ( FILE, $file ) || die " cant read $file \n" ;


my @chars;
my $text_length = 16;
while (my $line = <FILE>) {
  chomp($line);
  push @chars, $line;
}

my $seq1 = $chars[0];
my $seq2 = $chars[1];
my @seq1 = split('', $seq1);
my @seq2 = split('', $seq2);
my $length1 = length($seq1);
my $length2 = length($seq2);

my ($kmer1, $kmer2, %kmers1, %kmers2);
for (my $i = 0; $i <= $length1 - $text_length; $i++) {
  $kmer1 = substr($seq1, $i, $text_length);
  push @{ $kmers1{$kmer1} }, $i;
  $kmer2 = revcomp($kmer1);
  push @{ $kmers1{$kmer2} }, $i;
} 

for (my $i = 0; $i <= $length2 - $text_length; $i++) {
  $kmer1 = substr($seq2, $i, $text_length);
  push @{ $kmers2{$kmer1} }, $i;
}

my @keys = keys %kmers1;
my @keys2 = keys %kmers2;
my (@values1, @values2);
foreach my $k (@keys) {
  if ($kmers2{$k}) {
    @values2 = @{ $kmers2{$k} };
    @values1 = @{ $kmers1{$k} };
    foreach my $v (@values1) {
      foreach my $v2 (@values2) {
        print "($v, $v2)\n";
      }
    }
  }
}
#for (my $i = 0; $i < $nb_kmer1; $i++) {
#  for (my $j = 0; $j < $nb_kmer2; $j++) {
#    if ($kmers1[$i*2] eq $kmers2[$j*2]) {
#      print "($i, $j)\n";
#    }
#    if ($kmers1[$i*2+1] eq $kmers2[$j*2]) {
#      print "($i, $j)\n";
#    }
#  }
#}



sub revcomp {
  my ($seq) = @_;
  my @seq = split('', $seq);
  my $length = scalar(@seq);
  my @rev_char = @seq;
  my $rev_char;
  my $position = $length - 1;
  for (my $i = 0; $i < $length; $i++) {
    if ($seq[$i] eq 'A') {
      $rev_char[$position] = 'T';
    } elsif ($seq[$i] eq 'T') {
      $rev_char[$position] = 'A';
    } elsif ($seq[$i] eq 'C') {
      $rev_char[$position] = 'G';
    } elsif ($seq[$i] eq 'G') {
      $rev_char[$position] = 'C';
    }
    $position--;
  }
  for (my $i = 0; $i < $length ; $i++) {
    $rev_char .= $rev_char[$i];
  }
  return $rev_char;
}



