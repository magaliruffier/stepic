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
my %hash;
my %position_hash;
my %position_start;
my %leaf_hash;
my $length;
my $key;
my $position;
my $max = 2;
my ($start, $end, $position_start);
my $first_seq = $chars[0];
my @first_seq = split('', $first_seq);
my $total_length = scalar(@first_seq);
my $offset = 0;
my (@kmers, $kmer);
for (my $i = 3; $i < $total_length; $i++) {
  $offset = 0;
  while ($offset < $total_length - $i + 1) {
    $kmer = substr($first_seq, $offset, $i);
    push @kmers, $kmer;
    $offset++;
  }
}
foreach my $char (@kmers) {
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

my @result;
my %result;
my $result;
my $new_position = 0;

my %result_hash;
while (@first_seq) {
  $result = prefix_match(\@first_seq, \%position_start, \%leaf_hash);
print "Matching $result for @first_seq\n";
  if ($result) {
    push @{ $result{$result} }, $new_position;
    $result_hash{$result}++;
  }
  shift @first_seq;
  $new_position++;
}
my $longest = 0;
my $winner;
foreach my $char (@kmers) {
  if ($result{$char}) {
    if (scalar(@{ $result{$char} }) > 1) {
print "Looking at $char compared to $longest and $winner\n";
      if (length($char) > $longest) {
        $longest = length($char);
        $winner = $char;
      }
    }
  }
}
print $winner . " longest matching repeat\n";

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
