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

my $seq = $chars[0];
my @seqs;
my $seq_length = length($seq);
my $text_length = $seq_length;
my $position_hash;
my $substring;
while ($text_length > 0) {
  $substring = substr($seq, $seq_length - $text_length, $text_length);
  push @seqs, $substring;
  $text_length--;
}

my @seq;
my %hash;
my %position_hash;
my %position_start;
my $length;
my $key;
my $position;
my $max = 2;
my ($start, $end, $position_start);
my @positions;
foreach my $char (@seqs) {
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
      $positions[$start][$end] = $seq[$i];
      $start = $end - 1;
    }
    if ($position_hash{$position} && $position_hash{$position} ne $seq[$i]) {
      $position = $start . '-' . $max;
      $positions[$start][$max] = $seq[$i];
      $start = $max - 1;
      $end = $start + 1;
    }
    $positions[$start][$end] = $seq[$i];
    $position_start{$position_start} = $end;
    $position_hash{$position} = $seq[$i];
    $key = $position . "-" . $seq[$i];
    if (!$hash{$key}) {
      $max++;
      $hash{$key} = $seq[$i];
    }
  }
}


my $second_length;
my $initial_length = scalar(@positions);
#for (my $i = 0; $i < $initial_length; $i++) {
#  $second_length = scalar($positions[$i]);
#  for (my $j = 0; $j < $second_length; $j++) {
#    print $positions[$i][$j];
#  }
#}

my @values;
foreach my $k (keys %hash) {
  @values = split('-', $k);
  print $values[0] . " " . $values[1] . " " . $values[2] . "\n";
}

