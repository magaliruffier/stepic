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
my $length;
my $key;
my $position;
my $max = 2;
my ($start, $end, $position_start);
foreach my $char (@chars) {
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
}

my @values;
foreach my $k (keys %hash) {
  @values = split('-', $k);
  my $end = $values[1] - 1;
  print $values[0] - 1 . "->" . $end . ":" . $values[2] . "\n";
}

