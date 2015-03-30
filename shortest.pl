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

my $genome = $chars[1];
my $comparison_seq = $chars[0];
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


my $comparison_length = length($comparison_seq);
$index = 1;
my $min_length = $comparison_length;
my @shortest;
my $prefix_sequence;
my $true;

for (my $i = 0; $i < $comparison_length; $i++) {
  $suffix = substr($comparison_seq, $i, 1);
  $prefix = $suffix;
  $start = $suffix . '-' . 1;
  if (!$edge_prefix{$start}) {
    if (length($suffix) < $min_length) {
      push @shortest, $suffix;
      $min_length = length($suffix);
    }
    next;
  } else {
    $edge = $edge_prefix{$start};
    $sequence = $edge_label{$edge};
    $position = 0;
    $index = 0;
    $prefix_sequence = substr($sequence, $position, 1);
    $prefix = substr($comparison_seq, $i + $index, 1);
    $true = 1;
    while ($true) {
      $index++;
      if ($index > $min_length) { 
        $true = 0;
        next;
      }
      if ($prefix eq $prefix_sequence) {
        $position++;
        $prefix = substr($comparison_seq, $i + $index, 1);
        if (!$prefix) {
          $true = 0;
          last;
        }
        if ($position >= length($sequence)) {
          if ($edge_children{$edge}) {
            @children = @{ $edge_children{$edge} };
            $found = 0;
            foreach my $child (@children) {
              if ($edge_prefix{$child} eq $prefix) {
                $edge = $child;
                $sequence = $edge_label{$edge};
                $found = 1;
                $position = 0;
              }
              if ($found) {
                last;
              }
            }
            if (!$found) {
              push @shortest, substr($comparison_seq, $i, $index + 1);
              $min_length = $i + $index + 1;
              $true = 0;
            }
          } else {
            $true = 1;
          }
        }
        $prefix_sequence = substr($sequence, $position, 1);
      } else {
        push @shortest, substr($comparison_seq, $i, $index);
        $min_length = $index;
        $true = 0;
      }
    }
  }
}


my $big_length = $comparison_length;
my $winner;
foreach my $shortest(@shortest) {
  if (length($shortest) < $big_length) {
    $winner = $shortest;
    $big_length = length($shortest);
  }
}

print "Found winner $winner with $big_length\n";

