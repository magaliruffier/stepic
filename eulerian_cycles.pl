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
my @suffix;
my $nb_values = 0;
while (my $line = <FILE>) {
  chomp($line);
  @chars = split(' -> ', $line);
  $prefix = $chars[0];
  $suffix = $chars[1];
  @suffix = split(',', $suffix);
  foreach my $s (@suffix) {
    $nb_values++;
    push @{ $prefix_hash{$prefix} }, $s;
  }
}

my @keys = keys %prefix_hash;
my $key = $keys[0];
my @cycle = ($key);
my $value;
my $true = 1;
my %used_keys;
while ($true) {
  $value = $prefix_hash{$key}[0];
  $used_keys{$key}++;
  push @cycle, $value;
  shift @{ $prefix_hash{$key}};
  if (!$prefix_hash{$key}[0]) {
    delete $prefix_hash{$key};
  }
  $key = $value;
  if (!$prefix_hash{$key}) { $true = 0; }
}

@keys = keys %prefix_hash;
my @possible_keys = grep { $used_keys{$_} } @keys;
my $start = $possible_keys[0];
my @cycle2;

my $nb = 0;
while(@keys) {
  $key = $start;
  @cycle2 = ($key);
  $nb++;
  $true = 1;
  while ($true) {
    $used_keys{$key}++;
    $value = $prefix_hash{$key}[0];
    push @cycle2, $value;
    shift @{ $prefix_hash{$key}};
    if (!$prefix_hash{$key}[0]) {
      delete $prefix_hash{$key};
    }
    $key = $value;
    if (!$prefix_hash{$key}) { $true = 0; }
  }
  @keys = keys %prefix_hash;
  @possible_keys = grep { $used_keys{$_} } @keys;
  $start = $possible_keys[0];
  @cycle = @{ merge(\@cycle, \@cycle2) };
}

print $cycle[0];
shift @cycle;
foreach my $node (@cycle) {
  print "->" . $node;
}
print "\n";


sub merge {
  my $cycle = shift;
  my $cycle2 = shift;
  my @cycle = @$cycle;
  my @cycle2 = @$cycle2;
  my $length = scalar(@cycle);
  my $length2 = scalar(@cycle2);
  my $start = $cycle2[0];
  my @result_cycle = @cycle2;
  my $end;
  for (my $i = 0; $i < $length; $i++) {
    if ($cycle[$i] eq $start) {
      $end = $i;
      last;
    }
  }
  push @result_cycle, @cycle[$end+1..$length-1];
  push @result_cycle, @cycle[1..$end];
  return \@result_cycle;
}


