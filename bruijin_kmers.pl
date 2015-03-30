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
  $prefix = substr($line, 0, $length - 1);
  $suffix = substr($line, 1, $length);
  push @{ $prefix_hash{$prefix} }, $suffix;
  $seq_count++;
}

foreach my $key (sort {$a cmp $b} keys %prefix_hash) {
  print $key . " -> ";
  my @values = sort {$a cmp $b} keys %{{ map { $_ => 1 } @{ $prefix_hash{$key} }}};
  print $values[0];
  for (my $i = 1; $i < scalar(@values); $i++) {
    print "," . $values[$i];
  }
  print "\n";
}



