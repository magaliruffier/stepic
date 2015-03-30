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

my %edge_label;
my %position_hash;
my %edge_prefix;
my %edge_index;
my %edge_children;
my $children;
my @children;
my $edge;
my $start;
my $index;
my $sequence;

my $genome = $chars[0];
my $length = length($genome);
my $text_length = $length;
my ($suffix, $prefix);
my $position;
my $nb_edge = 1;
my $found = 0;
my $end = 0;
my $max_length = 0;

while ($text_length > 0) {
  $suffix = substr($genome, $length - $text_length, $text_length);
  $prefix = substr($suffix, 0, 1);
  $index = 1;
  $start = $prefix . '-' . $index;
  $found = 0;
  if ($edge_prefix{$start}) {
    $end = 0;
    $edge = $edge_prefix{$start};
    $position = 1;
    while (!$end) {
      $index = $edge_index{$edge};
      $sequence = $edge_label{$edge};
      if (length($sequence) < length($suffix) - $position) {
        $max_length = length($sequence);
      } else {
        $max_length = length($suffix) - $position;
      }
      for (my $i = $position; $i <= $max_length + $position - 1; $i++) {
        $index++;
        if (substr($sequence, $i - $position, 1) ne substr($suffix, $i + - 1, 1)) {
          $end = 1;
          $edge_label{$edge} = substr($sequence, 0, $i - $position);
          $edge_children{$nb_edge} = $edge_children{$edge};
          delete $edge_children{$edge};
          push @{ $edge_children{$edge} }, $nb_edge;
          $edge_prefix{$nb_edge} = substr($sequence, $i - $position, 1);
          $edge_label{$nb_edge} = substr($sequence, $i - $position, length($sequence) - $i + 1 + $position);
          $edge_index{$nb_edge} = $i;
          $nb_edge++;
          $edge_label{$nb_edge} = substr($suffix, $i - 1, length($suffix) - $i + 1);
          $edge_index{$nb_edge} = $i;
          $edge_prefix{$nb_edge} = substr($suffix, $i - 1, 1);
          push @{ $edge_children{$edge} }, $nb_edge;
          $nb_edge++;
          last;
        }
      }
      if ($end) {
        last;
      }
      $position = $index;
      $prefix = substr($suffix, $position - 1, 1);
      $start = $prefix . '-' . $index;
      if ($edge_children{$edge} ) {
        @children = @{ $edge_children{$edge} };
      } else {
        $end = 1;
        last;
      }
      #$end = 1;
      my $found = 0;
      foreach my $child (@children) {
        if ($edge_prefix{$child} eq $prefix) {
          $edge = $child;
          $found = 1;
        }
        if ($found) {
          last;
        }
      }
      if (!$found) {
        $end = 1;
        $edge_label{$nb_edge} = substr($suffix, $position - 1, length($suffix) - $position + 1) ;
        $edge_prefix{$nb_edge} = substr($suffix, $position - 1, 1);
        $edge_index{$nb_edge} = $position;
        push @{ $edge_children{$edge}}, $nb_edge;
        $nb_edge++;
      }
    }
  } else {
    $edge_label{$nb_edge} = $suffix;
    $edge_prefix{$start} = $nb_edge;
    $edge_index{$nb_edge} = 1;
    $edge_children{$nb_edge} = ();
    $nb_edge++;
  }
  $text_length--;
}


my $test_sequence = $chars[1];

foreach my $k (keys %edge_label) {
print $edge_label{$k} . "\n"; }




