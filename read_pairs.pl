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
my $distance = 300;
my ($length, $kmer, $offset);
my @kmers;
my $seq_count = 0;
my ($kmer1, $kmer2, $prefix, $suffix, $pre_overlap, $suf_overlap);
my %prefix_hash;
my %suffix_hash;
my %start_hash;
my %end_hash;
my @suffix;
my %hash;
my $nb_values = 0;
while (my $line = <FILE>) {
  chomp($line);
  @chars = split('\|', $line);
  $kmer1 = $chars[0];
  $length = length($kmer1);
  $kmer2 = $chars[1];
  $prefix = substr($kmer1, 0, $length - 1) . "|" . substr($kmer2, 0, $length - 1);
  $suffix = substr($kmer1, 1, $length - 1) . "|" . substr($kmer2, 1, $length - 1);
  $prefix_hash{$line} = $prefix;
  $suffix_hash{$line} = $suffix;
  $hash{$prefix} = $suffix;
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


my @keys = keys %hash;
my $key = $start;
my @cycle = ($key);
my $value;
my $true = 1;
my %used_keys;

while (@keys) {
  $value = $hash{$key};
  $used_keys{$key}++;
  push @cycle, $value;
  delete $hash{$key};
  $key = $value;
  @keys = keys %hash;
}

my $cycle_length = scalar(@cycle);
my $position;
my $first = $cycle[0];
my @split = split('\|', $first);
my $start_string = $split[0];
my $end_string = $split[1];
my ($start_sequence, $end_sequence);
for (my $i = 1; $i < $cycle_length; $i++) {
  @chars = split('\|', $cycle[$i]);
  $length = length($chars[1]);
  $start_sequence = substr($chars[0], $length - 1, 1);
  $start_string .= $start_sequence;
  $end_sequence = substr($chars[1], $length - 1, 1);
  $end_string .= $end_sequence;
}

my $text_length = length($end_string);
#print "Have found $start_string \n and $end_string\n";
#print length($start_string) . " start string length and $length end string length\n";
my $short_seq = substr($end_string, $text_length - $distance - $length - 1, $text_length);
my $final_sequence = $start_string . substr($end_string, $text_length - $distance - $length - 1, $text_length);
  

print "$final_sequence\n";



