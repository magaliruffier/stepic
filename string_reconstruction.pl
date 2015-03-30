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
my %start_hash;
my %end_hash;
my @suffix;
my $nb_values = 0;
while (my $line = <FILE>) {
  chomp($line);
  @kmers = split(' -> ', $line);
  $prefix = $kmers[0];
  $suffix = $kmers[1];
  $length = length($prefix);
  $prefix_hash{$prefix} = $suffix;
  $start_hash{$prefix}++;
  $end_hash{$suffix}++;
}

my $start;
foreach my $key (keys %start_hash) {
  if (!$end_hash{$key}) {
    $start = $key;
  } elsif ($start_hash{$key} > $end_hash{$key}) {
    $start = $key;
  }
}

my $end;
foreach my $key (keys %end_hash) {
  if (!$start_hash{$key}) {
    $end = $key;
  } elsif ($start_hash{$key} < $end_hash{$key}) {
    $end = $key;
  }
}

my @keys = keys %prefix_hash;
my $key = $start;
my @cycle = ($key);
my $value;
my $true = 1;
my %used_keys;
while (@keys) {
  $value = $prefix_hash{$key};
  $used_keys{$key}++;
  push @cycle, $value;
  delete $prefix_hash{$key};
  $key = $value;
  @keys = keys %prefix_hash;
}

print substr($cycle[0], 0, $length - 1);
foreach my $node (@cycle) {
  print substr($node, $length - 1, 1);
}
print "\n";



