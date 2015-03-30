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

my $string = shift @chars;
my @patterns = @chars;
my $length = length($string);
my @sequences = split('', $string);

my ($prefix, $suffix);
my (%prefix_count, %suffix_count);
my %hash;
my @ordered_sequences = sort {$a cmp $b} @sequences;
my %prefix_hash;
my %suffix_hash;
my $previous_symbol = '';
my %first_occurence;

for (my $i = 0; $i < $length; $i++) {
  $prefix = $sequences[$i];
  $suffix = $ordered_sequences[$i];
print "Considering $prefix and $suffix for $i\n";
  if ($suffix ne $previous_symbol) {
    $first_occurence{$suffix} = $i;
  }
  $prefix_count{$prefix}++;
  $suffix_count{$suffix}++;
  $hash{$prefix . '-' . $prefix_count{$prefix}} = $suffix . '-' . $suffix_count{$suffix};
  $prefix_hash{$prefix . '-' . $prefix_count{$prefix}} = $i;
  $suffix_hash{$suffix . '-' . $suffix_count{$suffix}} = $i;
  $previous_symbol = $suffix;
}


my $final_seq;
my ($current, $next, $correct_seq);


my ($count, @counts);
foreach my $pattern (@patterns) {
  $count = bwmatching($pattern);
print "Matching $pattern with $count\n";
  if ($count) { 
    print $count . " ";
  } else {
    print "0 ";
  }
}

print "\n";

sub bwmatching {
  my $pattern = shift;
  my @pattern_sequence = split('', $pattern);
  my $top = 0;
  my $bottom = $length - 1;
  my $symbol;
  while ($top <= $bottom) {
print "Have top $top and bottom $bottom for $pattern\n";
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
      return $bottom - $top + 1;
    }
  }
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

