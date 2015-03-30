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

my $string = $chars[0] . $chars[0];
my $length = length($chars[0]);
my $nb_sequences = scalar(@chars);
my @patterns;

# Create list of patterns
for (my $i = 1; $i < $nb_sequences; $i++) {
  push @patterns, $chars[$i];
}

my $seq;
my @sequences;

# Create bwt from initial string
for (my $i = 0; $i < $length; $i++) {
  $seq = substr($string, $i, $length);
  push @sequences, $seq;
}
my @ordered = sort { $a cmp $b } @sequences;

my $bwt = '';
for (my $j = 0; $j < $length; $j++) {
  $bwt .= substr($ordered[$j], $length - 1, 1);
}

#print "$bwt is bwt of " . $chars[0] . "\n";
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
for (my $i = 0; $i < $length; $i++) {
  $prefix = $sequences[$i];
  $suffix = $ordered_sequences[$i];
  if ($suffix ne $previous_symbol) {
    $first_occurence{$suffix} = $i;
#print "First occurence for $suffix at $i\n";
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
my $k_count = 5;
my $genome = $chars[0];
my @substrs = map {\substr $genome, $_} 0 .. length($genome) - 1;

my @sorted_genome = sort { $$a cmp $$b } @substrs;
my $count = 0;
my @partial_suffix;
my %partial_hash;
my $new_length;
foreach my $s (@sorted_genome) {
  $new_length = $length - length($$s);
#print "On position $count, we have " . $$s . " and $new_length \n";
  if (($length - length($$s)) % $k_count == 0) {
    $partial_suffix[$count] = $length - length($$s);
    $partial_hash{$count} = 1;
    #print "$count,";
    #print  $length - length($$s) . " \n";
  }
  $count++;
}

# Create partial count hash
my %count_hash;
my %all_hash;
my $c = 10;
my ($character, $key);
for (my $i = 0; $i < $length; $i++) {
  $character = $sequences[$i];
  $all_hash{$character}++;
  if ($i % $c == 0) {
    for (my $j = 0; $j <= $i; $j++) {
      foreach my $k (keys %all_hash) {
        $count_hash{$k . '-' . $i} = $all_hash{$k};
      }
    }
  }
  $all_hash{$character}++;
}
#foreach my $k (keys %count_hash) {
#print "Found $k with " . $count_hash{$k} . "\n";
#}


my $final_seq;
my ($current, $next, $correct_seq);


# Find occurences for each pattern
my @all_positions;
foreach my $pattern (@patterns) {
#print "Looking at $pattern\n";
  bwmatching($pattern);
}

my @sorted_positions = sort {$a cmp $b} @all_positions;
foreach my $pos (@sorted_positions) {
  print $pos . " ";
}
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
      while ($top <= $bottom) {
        $new_position = find_position($top);
#print "Found position $new_position for $pattern\n";
        push @all_positions, $new_position;
        #print "new position : $new_position\n";
        #print "Have $top and $bottom\n";
        $top++;
      }
      return;
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
#print "Have found " . $partial_suffix[$position] . " with $position and " . $partial_hash{$position} . "\n";
  $new_position = $partial_suffix[$position] + $count;
  return $new_position;
}

sub position_count {
  my $symbol = shift;
  my $position = shift;
#print "Running position count with $symbol and $position\n";
  my $count = 0;
  for (my $i = 0; $i < $position; $i++) {
    if ($sequences[$i] eq $symbol) {
      $count++;
    }
  }
  return $count;
}

