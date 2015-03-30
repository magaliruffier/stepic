#!/usr/local/ensembl/bin/perl -w




use strict;
use Getopt::Long;

my $file;

&GetOptions(
'file:s'      => \$file);


open ( FILE, $file ) || die " cant read $file \n" ;


my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push (@chars, $line);
}

my $text = $chars[0];

sub suffix {
  my $string = shift;
  my @array = sort { substr( $string, $a ) cmp substr( $string, $b ) } 0..length($string)-1;
  $_++ for @array;
  return @array;
}

my ($previous, $current, $winner, $common_suffix, $position, $old_position);
my $max_length = 0;
my @result = suffix($text);

my @array;
foreach my $r (@result) {
  push @array, $r-1;
}
my $length = scalar(@result);
for (my $i = 0; $i < $length; $i++) {
  $position = $array[$i];
  $old_position = $array[$i-1];
  $previous = substr($text, $old_position);
  $current = substr($text, $position);
  $common_suffix = find_match($previous, $current);
  if (length($common_suffix) > $max_length) {
    $max_length = length($common_suffix);
    $winner = $common_suffix;
  }
}

print "$winner\n";


sub find_match {
  my $first_seq = shift;
  my $second_seq = shift;
  my $length = length($first_seq);
  my $index = 1;
  my $first_prefix = substr($first_seq, 0, 1);
  my $second_prefix = substr($second_seq, 0, 1);
  my $true = 1;
  while ($true) {
    if ($first_prefix ne $second_prefix) {
      return substr($first_seq, 0, $index - 1);
    } else {
      $index++;
      $first_prefix = substr($first_seq, 0, $index);
      $second_prefix = substr($second_seq, 0, $index);
    }
  }
}

