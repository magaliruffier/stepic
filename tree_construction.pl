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
  $suffix = substr($genome, $text_length - 1, $length);
  $prefix = substr($suffix, 0, 1);
  $index = 1;
  $start = $prefix . '-' . $index;
  $found = 0;
#print "Running for $suffix and $start\n";
  if ($edge_prefix{$start}) {
    $end = 0;
    $edge = $edge_prefix{$start};
    $position = 1;
    while (!$end) {
#print "Starting with $position and $edge\n";
      $index = $edge_index{$edge};
      $sequence = $edge_label{$edge};
      if (length($sequence) < length($suffix) - $position) {
        $max_length = length($sequence);
      } else {
        $max_length = length($suffix) - $position;
      }
#print "Found max $max_length compared to $position as well as " . length($suffix) . " and " . length($sequence) ." sequence $sequence\n";
      for (my $i = $position; $i < $max_length + $position; $i++) {
        $index++;
#print "First step is " .substr($sequence, $i - $position, 1) . " and " . substr($suffix, $i - 1, 1) . " when comparing $sequence and $suffix based on $i, $position, $index and $max_length\n";
        if (substr($sequence, $i - $position, 1) ne substr($suffix, $i + - 1, 1)) {
#print "Have a mismatch, creating new edge for " . substr($sequence, 0, $i - $position) . ", " . substr($sequence, $i - $position, length($sequence) - $i + $position + 1) . " and " .substr($suffix, $i - 1, length($suffix) - $i + 1) . " with $nb_edge\n";
          $end = 1;
          $edge_label{$edge} = substr($sequence, 0, $i - $position);
          $edge_children{$nb_edge} = $edge_children{$edge};
          delete $edge_children{$edge};
          push @{ $edge_children{$edge} }, $nb_edge;
          $edge_prefix{$nb_edge} = substr($sequence, $i - $position, 1);
          $edge_label{$nb_edge} = substr($sequence, $i - $position, length($sequence) - $i + 1 + $position);
#print "Have stored label " . substr($sequence, $i-$position, length($sequence)-$i+1+$position) . " using $sequence, $i, $position\n";
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
#foreach my $label (keys %edge_label) {
#print $edge_label{$label} . " are the new edges for $label\n";
#}
        last;
      }
      $position = $index;
      $prefix = substr($suffix, $position - 1, 1);
      $start = $prefix . '-' . $index;
#print "New position $position for $prefix and $start\n";
      if ($edge_children{$edge} ) {
#print "Children are found for $edge\n";
        @children = @{ $edge_children{$edge} };
      } else {
        $end = 1;
        last;
      }
      #$end = 1;
      my $found = 0;
#print "About to start children loop for $edge\n";
      foreach my $child (@children) {
#print "Looking up $child, comparing " . $edge_prefix{$child} . " with $prefix\n";
        if ($edge_prefix{$child} eq $prefix) {
#print "$child has prefix " . $edge_prefix{$child} . "\n";
#print "$child also has full sequence " . $edge_label{$child} . " sequence\n";
          $edge = $child;
          $found = 1;
        }
        if ($found) {
          last;
        }
      }
      if (!$found) {
#print "Did not find child, adding new child for " . substr($suffix, $position - 1, length($suffix) - $position + 1) . "\n";
        $end = 1;
        $edge_label{$nb_edge} = substr($suffix, $position - 1, length($suffix) - $position + 1) ;
        $edge_prefix{$nb_edge} = substr($suffix, $position - 1, 1);
        $edge_index{$nb_edge} = $position;
#print "Looking at $nb_edge and adding children for $edge\n";
        push @{ $edge_children{$edge}}, $nb_edge;
#print "Now have " . scalar(@{$edge_children{$edge}}) . " children\n";
        $nb_edge++;
      }
    }
  } else {
    $edge_label{$nb_edge} = $suffix;
    $edge_prefix{$start} = $nb_edge;
    $edge_index{$nb_edge} = 1;
#print "Have no children for $nb_edge\n";
    $edge_children{$nb_edge} = ();
    $nb_edge++;
  }
  $text_length--;
}


foreach my $k (keys %edge_label) {
  if ($edge_label{$k}) {
    print $edge_label{$k} . "\n";
  }
}



