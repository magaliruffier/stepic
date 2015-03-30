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

my $min_length = 0;
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
      for (my $i = $position; $i < $max_length + $position; $i++) {
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

#foreach my $k (keys %edge_label) {
#  if ($edge_label{$k}) {
#    print $edge_label{$k} . "\n";
#  }
#}

#my (@kmers, $kmer, $offset);
#for (my $i = 3; $i < length($genome); $i++) {
#  $offset = 0;
#  while ($offset < length($genome) - $i + 1) {
#    $kmer = substr($genome, $offset, $i);
#    push @kmers, $kmer;
#    $offset++;
#  }
#}


my (@seq, $true, $prefix_sequence, $combined_length);
$index = 1;
$position = 0;
my %repeats;
my $offset = 0;
my $found_repeat = 0;
my $running_length = int(length($genome)/2) + 1;
#$running_length = length($genome);
#print "Using $genome\n";
#$running_length = 85;
#$min_length = 75;

for (my $i = $running_length; $i > $min_length; $i--) {
  $offset = 0;
  if ($found_repeat) { last; }
  while ($offset < length($genome) - $i + 1) {
    my $char = substr($genome, $offset, $i);
#print "Starting with $char at $offset and $i\n";
    $offset++;
    $position = 0;
    $combined_length = 0;
    @seq = split('', $char);
    $start = $seq[$position]. '-' . 1;
    if (!$edge_prefix{$start}) {
      next;
    } else {
      $edge = $edge_prefix{$start};
      $sequence = $edge_label{$edge};
      $index = 0;
      $prefix_sequence = substr($sequence, $index, 1);
      $prefix = $seq[$position];
      $true = 1;
      while ($true) {
        $index++;
        if ($prefix eq $prefix_sequence) {
          $position++;
#print "Just compared $prefix and $prefix_sequence, with $position and index $index. And testing " . $seq[$position] . "\n";
          $prefix = $seq[$position];
          if (!$prefix) {
            if ($repeats{$char}) {
              $found_repeat = 1;
            }
            $repeats{$char}++;
#print "Reached the end of $char, already have " . $repeats{$char} . "\n";
            $true = 0;
            last;
          }
          if ($position >= $combined_length + length($sequence) && $position < length($char) - 1) {
#print "Wanted children because $position, $index and $i do not match " . length($sequence) . " nor " . length($char) . " or $combined_length\n";
            if ($edge_children{$edge}) {
              @children = @{ $edge_children{$edge} };
              $found = 0;
              foreach my $child (@children) {
                if ($edge_prefix{$child} eq $prefix) {
#print "Looking for child by comparing $prefix and " . $edge_prefix{$child} . " for $child\n";
                  $edge = $child;
                  $sequence = $edge_label{$edge};
                  $found = 1;
                  $combined_length += $index;
                  $index = 0;
                }
              }
              #if (!$found && $position < $i - 2) {
              #  $true = 0;
              #}
            } else {
              $true = 1;
            }
          } elsif ($position == length($char) - 1) {
            if ($repeats{$char}) {
              $found_repeat = 1;
#print "Perfect match for $position and $char\n";
            }
            $repeats{$char}++;
            $true = 0;
            last;
          }
          $prefix_sequence = substr($sequence, $index, 1);
#print "Now comparing $prefix_sequence and some $prefix from @seq and $sequence based on $position as well as $index while $true\n";
        } else {
          $true = 0;
        }
      }
    }
  }
}


my @ordered = map { $_->[0] } sort { $b->[1] <=> $a->[1] } map { [$_, length($_)] } keys %repeats ;

foreach my $repeat (@ordered) {
  if ($repeats{$repeat} > 1) {
    print $repeat . "\n";
    last;
  }
}



