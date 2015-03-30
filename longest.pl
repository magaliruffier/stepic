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
my %edge_depth;

my $genome = $chars[0];
my $length = length($genome);
my $text_length = $length;
my ($suffix, $prefix);
my $position;
my $nb_edge = 1;
my $found = 0;
my $end = 0;
my $max_length = 0;
my %parent_edge;

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
          $parent_edge{$nb_edge} = $edge;
          $nb_edge++;
          $edge_label{$nb_edge} = substr($suffix, $i - 1, length($suffix) - $i + 1);
print "And adding new index $i for " . substr($suffix, $i - 1, length($suffix) - $i + 1) . "\n";
          $edge_index{$nb_edge} = $i;
          $parent_edge{$nb_edge} = $edge;
          $edge_prefix{$nb_edge} = substr($suffix, $i - 1, 1);
          push @{ $edge_children{$edge} }, $nb_edge;
          $nb_edge++;
          last;
        }
      }
      if ($end) {
foreach my $label (keys %edge_label) {
print $edge_label{$label} . " are the new edges for $label with index " . $edge_index{$label} . "\n";
}
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
print "Adding other index $position for " . substr($suffix, $position - 1, length($suffix) - $position + 1) . "\n";
        $edge_index{$nb_edge} = $position;
        $parent_edge{$nb_edge} = $edge;
        push @{ $edge_children{$edge}}, $nb_edge;
        $nb_edge++;
      }
    }
  } else {
    $edge_label{$nb_edge} = $suffix;
    $edge_prefix{$start} = $nb_edge;
print "Adding index 1 for $suffix\n";
    $edge_index{$nb_edge} = 1;
    $edge_children{$nb_edge} = ();
    $nb_edge++;
  }
  $text_length--;
}


my %repeat_hash;
my $winner;
my $max_depth = 0;
foreach my $key (keys %edge_label) {
  if ($edge_children{$key}) {
    if ($edge_index{$key} > $max_depth) {
      $max_depth = $edge_index{$key};
    }
  }
}

my $longest = 0;
my $sequence_length;
foreach my $key (keys %edge_label) {
#print "Looking at $key " . $edge_label{$key} . " with " . $edge_index{$key} . " and " . $edge_children{$key} .  " compared to $max_depth\n";
  if ($edge_index{$edge} == $max_depth && $edge_children{$key}) {
    $sequence_length = length($edge_label{$key});
    if ($sequence_length > $longest) {
      $winner = $edge_label{$key};
      $longest = $sequence_length;
    }
  }
}

print "Found winer $winner\n";
  
#my $max = $ordered[0];
#print "Deepest edge is $max\n";
#foreach my $edge (keys %edge_index) {
#  if ($edge_index{$edge} == $max) {
#print $edge_label{$edge} . " is of depth $max\n";
#    if (length($edge_label{$edge}) > length($winner)) {
#      $winner = $edge_label{$edge};
#    }
#  }
#}


print "$winner\n";



