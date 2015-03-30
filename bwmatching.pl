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

my $string = shift @chars;#$chars[0];
my $patterns = $chars[0];
my @patterns = split(/ /, $patterns);
#my @patterns = @chars;
my $length = length($string);
my @sequences = split('', $string);

my ($prefix, $suffix);
my (%prefix_count, %suffix_count);
my %hash;
my @ordered_sequences = sort {$a cmp $b} @sequences;
my %prefix_hash;
my %suffix_hash;

for (my $i = 0; $i < $length; $i++) {
  $prefix = $sequences[$i];
  $suffix = $ordered_sequences[$i];
  $prefix_count{$prefix}++;
  $suffix_count{$suffix}++;
  $hash{$prefix . '-' . $prefix_count{$prefix}} = $suffix . '-' . $suffix_count{$suffix};
  $prefix_hash{$prefix . '-' . $prefix_count{$prefix}} = $i;
  $suffix_hash{$suffix . '-' . $suffix_count{$suffix}} = $i;
}

my $final_seq;
my ($current, $next, $correct_seq);
my @last_to_first;
$current = $ordered_sequences[0] . '-1';
for (my $j = 0; $j < $length; $j++) {
  $next = $hash{$current};
  $last_to_first[$prefix_hash{$current}] = $suffix_hash{$current};
#print "Have " . $suffix_hash{$current} . " for $j and $next as well as " . $prefix_hash{$current} . " and " . $prefix_hash{$next} . "\n";
  $current = $next;
}


my ($count, @counts);
foreach my $pattern (@patterns) {
#print "Running for $pattern\n";
  $count = bwmatching($pattern);
  print $count . " ";
}

print "\n";

sub bwmatching {
  my $pattern = shift;
  my @pattern_sequence = split('', $pattern);
  my $top = 0;
  my $bottom = $length - 1;
  my $symbol;
  my ($top_index, $bottom_index, $found);
#print "Now considering $pattern with @pattern_sequence, with $top and $bottom\n";
  while ($top <= $bottom) {
#print "Have top $top and bottom $bottom for $pattern\n";
    if (scalar(@pattern_sequence) > 0) {
      $symbol = pop @pattern_sequence;
      $found = 0;
      $top_index = $bottom;
      $bottom_index = $top;
      for (my $k = $top; $k <= $bottom; $k++) {
        if ($sequences[$k] eq $symbol) {
#print "Matching for $k, $pattern and $symbol, on positions $top_index and $bottom_index\n";
          $found = 1;
          if ($k < $top_index) {
            $top_index = $k;
          }
          if ($k > $bottom_index) {
            $bottom_index = $k;
          }
        }
      }
      if ($found) {
        $top = $last_to_first[$top_index];
        $bottom = $last_to_first[$bottom_index];
#print "Updated $top and $bottom with $top_index and $bottom_index\n";
      } else {
        return 0;
      }
    } else {
#print "Have nothing left in pattern, returning $bottom and $top\n";
      return $bottom - $top + 1;
    }
  }
}

