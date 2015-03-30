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
my $text_length = 12;
my ($length, $kmer, $offset);
my %hash;
my @kmers;
my $seq_count = 0;
my ($prefix, $suffix, $pre_overlap, $suf_overlap);
my %prefix_hash;
my %suffix_hash;
while (my $line = <FILE>) {
  chomp($line);
  $length = length($line);
  $offset = 0;
  while ($offset < $length - $text_length + 1) {
    $kmer = substr($line, $offset, $text_length);
    $prefix = substr($line, $offset, $text_length - 1);
    $suffix = substr($line, $offset + 1, $text_length - 1);
    $prefix_hash{$suffix} = $prefix;
    $suffix_hash{$suffix} = $kmer;
    $offset++;
  }
  $seq_count++;
}

my %overlap_hash;
foreach my $prefix (keys %prefix_hash) {
#print "Considering $prefix for " . $prefix_hash{$prefix} . "\n";
  foreach my $suffix (keys %prefix_hash) {
#print "Comparing with $suffix for " . $suffix_hash{$suffix} . "\n";
#print "Making sure we don't match on " . $suffix_hash{$suffix} . " and " . $suffix_hash{$prefix_hash{$prefix}}. " here\n";
    if ($prefix eq $prefix_hash{$suffix} && $suffix_hash{$suffix} ne $suffix_hash{$prefix}) {
      push @{ $overlap_hash{$prefix} }, $suffix;
    }
  }
}

foreach my $key (sort {$a cmp $b} keys %overlap_hash) {
  print $key . " -> ";
  my @values = sort {$a cmp $b} @{ $overlap_hash{$key} };
  print $values[0];
  for (my $i = 1; $i < scalar(@values); $i++) {
    print "," . $values[$i];
  }
  print "\n";
}

print "\n";



