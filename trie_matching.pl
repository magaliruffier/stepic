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
  $leaf_hash{$position_start} = 1;
}

my $first_seq = shift @chars;
my @first_seq = split('', $first_seq);
my $total_length = scalar(@first_seq);
my @result;
my %result;
my $result;
my $new_position = 0;

while (@first_seq) {
  $result = prefix_match(\@first_seq, \%position_start, \%leaf_hash);
  if ($result) {
    #$new_position = $total_length = scalar(@first_seq);
    push @{ $result{$result} }, $new_position;
    #print scalar(@first_seq) . " position on sequence for @$result\n";
  }
  shift @first_seq;
  $new_position++;
}
foreach my $char (@chars) {
  my @values = sort {$a <=> $b} @{ $result{$char} };
  foreach my $v (@values) {
    print "$v ";
  }
  #print "\n";
}
print "\n" ;

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
