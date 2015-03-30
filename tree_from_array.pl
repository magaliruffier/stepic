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

my $string = $chars[0];
my @suffix_array = split(/, /, $chars[1]);
my @lcp_array = split(/, /, $chars[2]);


my $length = scalar(@suffix_array);

my %edge;
my $seq;
my ($position, $start, $end, $previous, $intermediate, $previous_edge, $next_edge, $current_length);
my $nb_edge = 0;
my @previous_edges;
my @current_edges;
my $index = 0;

for (my $i = 0; $i < $length; $i++) {
  $position = $suffix_array[$i];
  $start = $lcp_array[$i];
  $end = $suffix_array[$i-1];
  $seq = substr($string, $position);
  $previous = substr($string, $end);
#print "Looking at $seq for $position and $previous for $end with $start\n";
  if ($start == 0) {
    $edge{$nb_edge} = $seq;
    @previous_edges = ($nb_edge);
#print "Adding $seq and $nb_edge with $start\n";
    $nb_edge++;
  } else {
    $previous_edge = shift @previous_edges;
#print "About to loop with $previous_edge which is " . $edge{$previous_edge}  . "\n";
    $index = 0;
    $current_length = length($edge{$previous_edge});
    @current_edges = ();
    while ($current_length + $index < $start) {
      push @current_edges, $previous_edge;
      $previous_edge = shift @previous_edges;
      $index += $current_length;
      $current_length = length($edge{$previous_edge});
    }
#print "Ran on loop for $index and $start, found $previous_edge with $current_length compared to $start and " . $edge{$previous_edge} . "\n";
    #$edge{$previous_edge} = substr($edge{$previous_edge}, 0, $start - $index);
    if ($start != $current_length + $index) {
#print "No perfect match for " . $edge{$previous_edge} . " and " . substr($edge{$previous_edge}, $start - $index)  . " added for $nb_edge\n";
      $edge{$nb_edge} = substr($edge{$previous_edge}, $start - $index);
#print $edge{$nb_edge} . " before increment\n";
      $nb_edge++;
#print $edge{$nb_edge-1} . " after increment\n";
      $edge{$previous_edge} = substr($edge{$previous_edge}, 0, $start - $index);
    }
#print "Added " . $edge{$nb_edge-1} . " and " . substr($previous, $start) . " as well as " . $edge{$previous_edge} . " based on $start and $index, with $nb_edge \n";
    push @current_edges, $previous_edge;
    $edge{$nb_edge} = substr($seq, $start);
#print "Now adding " . substr($seq, $start) . " for $nb_edge\n";
    push @current_edges, $nb_edge;
    $nb_edge++;
    @previous_edges = @current_edges;
  }  
#foreach my $key (sort {$a <=> $b} keys %edge) {
#print "Have key " . $edge{$key} . " wit index $key\n"; }
}

foreach my $key (sort {$edge{$a} cmp $edge{$b}} keys %edge) {
  print $edge{$key} . "\n";
}
