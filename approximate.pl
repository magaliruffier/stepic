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

my $string = $chars[0] .  $chars[0];
my $length = length($chars[0]);

# Create list of patterns
my @patterns = split(/ /, $chars[1]);
#print "Will consider " . scalar(@patterns) . " patterns for genome of length $length\n";

my $d = $chars[2];

my $seq;
my @sequences;

# Create bwt from initial string
#print "Create bwt for initial string\n";
for (my $i = 0; $i < $length; $i++) {
  $seq = substr($string, $i, $length);
  push @sequences, $seq;
}
my @ordered = sort { $a cmp $b } @sequences;

my $bwt = '';
for (my $j = 0; $j < $length; $j++) {
  $bwt .= substr($ordered[$j], $length - 1, 1);
}

@sequences = split('', $bwt);


my ($prefix, $suffix);
my (%prefix_count, %suffix_count);
my %hash;
my @ordered_sequences = sort {$a cmp $b} @sequences;
my %prefix_hash;
my %suffix_hash;
my $previous_symbol = '';
my %first_occurence;
my %special_hash;

# Create position hash for all suffixes
#print "Create position hash\n";
for (my $i = 0; $i < $length; $i++) {
  $prefix = $sequences[$i];
  $suffix = $ordered_sequences[$i];
  if ($suffix ne $previous_symbol) {
    $first_occurence{$suffix} = $i;
  }
  $prefix_count{$prefix}++;
  $suffix_count{$suffix}++;
  $hash{$prefix . '-' . $prefix_count{$prefix}} = $suffix . '-' . $suffix_count{$suffix};
  $prefix_hash{$prefix . '-' . $prefix_count{$prefix}} = $i;
  $suffix_hash{$suffix . '-' . $suffix_count{$suffix}} = $i;
#print "Mapping $prefix-" . $prefix_count{$prefix} . " on $suffix-" . $suffix_count{$suffix} . " for " . $sequences[$i] . " and " . $ordered_sequences[$i] . " on position $i\n";
  $special_hash{$prefix . '-' . $i} = $prefix . '-' . $prefix_count{$prefix};
  $previous_symbol = $suffix;
}

# Create partial suffix array
#print "Create partial suffix array\n";
my $k_count = 5;
my $genome = $chars[0];
my @substrs = map {\substr $genome, $_} 0 .. length($genome) - 1;

my @sorted_genome = sort { $$a cmp $$b } @substrs;
my $count = 0;
my @partial_suffix;
my %partial_hash;
my $new_length;
#print "Create partial hash count\n";
foreach my $s (@sorted_genome) {
  $new_length = $length - length($$s);
  if (($length - length($$s)) % $k_count == 0) {
    $partial_suffix[$count] = $length - length($$s);
    $partial_hash{$count} = 1;
    #print "$count,";
    #print  $length - length($$s) . " \n";
  }
  $count++;
}

#print scalar localtime . " ";
#print "Starting partial count hash creation\n";
# Create partial count hash
my %count_hash;
my %all_hash;
my $c = 10;
my ($character, $key);
for (my $i = 0; $i < $length; $i++) {
  $character = $sequences[$i];
#  if ($i % $c == 0) {
    #for (my $j = 0; $j <= $i; $j++) {
      foreach my $k (keys %all_hash) {
        $count_hash{$k . '-' . $i} = $all_hash{$k};
      }
    #}
#  }
  $all_hash{$character}++;
}
#print scalar localtime . " ";
#print "Finished partial count hash creation\n";
foreach my $k (keys %all_hash) {
  $count_hash{$k . '-' . $length} = $all_hash{$k};
}

my $final_seq;
my ($current, $next, $correct_seq);


# Find occurences for each pattern
#print "Loop through patternx\n";
my ($k, $pattern_length, $found_positions, $partial_pattern, $pattern_seq, $genome_seq, $total_mismatch, $adjusted_position, $partial_genome, @partial_genome, @string_pattern);
my %pattern_positions;
my @found_positions;
while (my $pattern = shift @patterns) {
  $pattern_length = length($pattern);
  $k = int($pattern_length/($d+1));
#print scalar localtime . " ";
  for (my $i = 0; $i <= $d; $i++) {
    if ($i == $d) {
      $partial_pattern = substr($pattern, $i*$k);
#print "Added partial pattern $partial_pattern with $i and $k\n";
    } else {
      $partial_pattern = substr($pattern, $i*$k, $k);
    }
#print "Running for $partial_pattern and $pattern on $i and $k for $d\n";
    $found_positions = bwmatching($partial_pattern);
    if (!$found_positions) {
      next;
    }
    foreach my $found_position (@$found_positions) {
#print scalar localtime . " ";
#print "Partial $partial_pattern on position $found_position for $pattern and index $i compared to $length and $pattern_length";
#print " with initial sequence " . substr($genome, $found_position, $pattern_length) . "\n";
      $adjusted_position = $found_position - $i*$k;
      $partial_genome = substr($genome, $adjusted_position, $pattern_length);
      @partial_genome = split('', $partial_genome);
      @string_pattern = split('', $pattern);
      if ($adjusted_position < 0 || $adjusted_position >= $length || $adjusted_position+$pattern_length > $length) {
#print "Skipping for $found_position, $i, $pattern_length and $length\n";
        next;
      }
      $total_mismatch = 0;
      for (my $l = 0; $l < $i*$k; $l++) {
        #$pattern_seq = substr($pattern, $l, 1);
        #$genome_seq = substr($genome, $found_position + $l - $i*$k, 1);
        #$genome_seq = substr($partial_genome, $l, 1);
#print scalar localtime . " ";
#print "Comparing start $pattern_seq with $genome_seq and " . substr($partial_genome, $l, 1) . " for $l, $i and $k\n";
        #if ($pattern_seq ne $genome_seq) {
        if ($partial_genome[$l] ne $string_pattern[$l]) {
          $total_mismatch++;
        }
        if ($total_mismatch > $d) {
          last;
        }
      }
      for (my $j = ($i+1)*$k; $j < $pattern_length; $j++) {
        if ($i == $d) {
          last;
        }
        #$pattern_seq = substr($pattern, $j, 1);
        #$genome_seq = substr($genome, $found_position + $j - $k*$i, 1);
        #$genome_seq = substr($partial_genome, $j, 1);
#print scalar localtime . " ";
#print "Comparing end $pattern_seq with $genome_seq with $i and $j as well as $found_position\n";
        #if ($pattern_seq ne $genome_seq) {
        if ($string_pattern[$j] ne $partial_genome[$j]) {
          $total_mismatch++;
        }
        if ($total_mismatch > $d) {
          last;
        }
        #print substr($pattern, $j, 1) . " compared with " . substr($genome, $found_position + $j, 1) . " on positions $j\n";
      }
      if ($total_mismatch <= $d) {
        $adjusted_position = $found_position - $i*$k;
        $pattern_positions{$adjusted_position}++;
        #print scalar localtime . " ". substr($genome, $found_position - $i*$k, $pattern_length) . " matches $pattern on position " . ($found_position -$i*$k) . "\n";
      }
    }
  }
  foreach my $key (keys %pattern_positions) {
    push @found_positions, $key;
    delete $pattern_positions{$key};
  }
}

my @sorted_positions = sort {$a cmp $b} @found_positions;
foreach my $pos (@sorted_positions) {
  print $pos . " ";
}
#print "\n";


print "\n";

sub bwmatching {
  my $pattern = shift;
  my @pattern_sequence = split('', $pattern);
  my $top = 0;
  my $bottom = $length - 1;
  my $symbol;
  my $new_position;
  while ($top <= $bottom) {
#print "Have top $top and bottom $bottom for $pattern\n";
    if (scalar(@pattern_sequence) > 0) {
      $symbol = pop @pattern_sequence;
#print "Now looking at $symbol, known on position " . $first_occurence{$symbol} . "\n";
      if ($top <= $bottom) {
        $top = $first_occurence{$symbol} + position_count($symbol, $top);
        $bottom = $first_occurence{$symbol} + position_count($symbol, $bottom + 1) - 1;
#print "Updated $top and $bottom for $symbol\n";
      } else {
        return 0;
      }
    } else {
#print "Have nothing left in pattern, returning $bottom and $top\n";
      my @all_positions;
      while ($top <= $bottom) {
        $new_position = find_position($top);
        push @all_positions, $new_position;
        #print "new position : $new_position\n";
        #print "Have $top and $bottom\n";
        $top++;
      }
      return \@all_positions;
    }
  }
}

sub find_position {
  my $position = shift;
  my $new_position;
  my $count = 0;
  my $key;
#print "Starting with position $position\n";
  while (!$partial_hash{$position}) {
    $key = $special_hash{$sequences[$position] . '-' . $position};
#print " sequence for " . $sequences[$position] . " and $position ";
#print "is with $key here as well as " . $prefix_hash{$key} . " and " . $suffix_hash{$key} . "\n";
    $position = $suffix_hash{$key};
#print "Not a multiple, now moving to $position and $count\n";
    $count++;
  }
#print "Have found " . $partial_suffix[$position] . " with $position and " . $partial_hash{$position} . " with $count\n";
  $new_position = $partial_suffix[$position] + $count;
  return $new_position;
}

sub position_count {
  my $symbol = shift;
  my $position = shift;
#print "Running position count with $symbol and $position\n";
  my $count = 0;
  my $key = $symbol . "-" . $position;
  if ($count_hash{$key}) {
    $count = $count_hash{$key};
  }
#  for (my $i = 0; $i < $position; $i++) {
#    if ($sequences[$i] eq $symbol) {
#      $count++;
#    }
#  }
#print "Found $count compared to " . $count_hash{$key} . "\n";
  return $count;
}

