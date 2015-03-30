#!/usr/local/ensembl/bin/perl -w




use strict;
use Getopt::Long;

my $file;
my $matrix;

&GetOptions(
'file:s'      => \$file,
'matrix:s'    => \$matrix ) ;


open ( FILE, $file ) || die " cant read $file \n" ;


my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push (@chars, $line);
}

my @seq;
my $seq = $chars[0];
my @sequences = split('', $seq);
my %hash;
my %position_hash;
my %position_start;
my %leaf_hash;
my $length;
my $key;
my $position;
my $max = 2;
my ($start, $end, $position_start);
foreach my $char (@sequences) {
  @seq = split('', $char);
  $length = scalar(@seq);
  $start = 0;
  $end = $start + 1;
  for (my $i = 0; $i < $length; $i++) {
    $start++;
    $end++;
    $position_start = $start. "-" . $seq[$i];
    $position = $start . '-' . $end; 
    if ($position_start{$position_start}) {
      $end = $position_start{$position_start};
      $position = $start . "-" . $end;
      $start = $end - 1;
    }
    if ($position_hash{$position} && $position_hash{$position} ne $seq[$i]) {
      $position = $start . '-' . $max;
      $start = $max - 1;
      $end = $start + 1;
    }
    $position_start{$position_start} = $end;
    $position_hash{$position} = $seq[$i];
    $key = $position . "-" . $seq[$i];
    if (!$hash{$key}) {
      $max++;
      $hash{$key} = $seq[$i];
    }
  }
  $leaf_hash{$position_start} = 1;
}


my $total_length = length($chars[0]);
my $offset = 0;
my (@kmers, $kmer);
for (my $i = 3; $i < $total_length; $i++) {
  $offset = 0;
  while ($offset < $total_length - $i + 1) {
    $kmer = substr($seq, $offset, $i);
    push @kmers, $kmer;
    $offset++;
  }
}

my $first_seq = shift @chars;
my @first_seq = split('', $first_seq);
my @result;
my %result;
my $result;
my $new_position = 0;

my %repeat_hash;
while (@kmers) {
  $result = prefix_match(\@kmers, \%position_start, \%leaf_hash);
  if ($result) {
    $repeat_hash{$result}++;
    push @{ $result{$result} }, $new_position;
  }
  shift @kmers;
  $new_position++;
}

my ($repeat_length, $winner);
my $max_length = 0;
foreach my $key (keys %repeat_hash) {
  if ($repeat_hash{$key} > 1) {
    $repeat_length = length($key);
    if ($repeat_length > $max_length) {
      $winner = $key;
      $max_length = $repeat_length;
    }
  }
}
print "Winner is $winner\n";

sub prefix_match {
  my $first_seq = shift;
  my $hash = shift;
  my $leaf_hash = shift;
  my @seq = @$first_seq;
  my %hash = %$hash;
  my %leaf_hash = %$leaf_hash;
  my $symbol = $seq[0];
  my $start = 1;
  my $key = 1 . '-' . $symbol;
  my @symbols = ($symbol);
  my $symbols = $symbol;
  my @result;
  my $true = 1;
  while ($true) {
    if ($leaf_hash{$key}) {
      return $symbols;
    } elsif ($hash{$key}) {
      $symbol = $seq[$start];
      $key = $hash{$key}. '-' . $symbol;
      $symbols .= $symbol;
      $start++;
    } else {
      return;
    }
  }
}
