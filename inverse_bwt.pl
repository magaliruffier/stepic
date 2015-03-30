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
my $length = length($string);
my @sequences = split('', $string);

my @ordered_sequences = sort {$a cmp $b} @sequences;


my ($prefix, $suffix);
my (%prefix_count, %suffix_count);
my %hash;

for (my $i = 0; $i < $length; $i++) {
  $prefix = $sequences[$i];
  $suffix = $ordered_sequences[$i];
  $prefix_count{$prefix}++;
  $suffix_count{$suffix}++;
  $hash{$prefix . '-' . $prefix_count{$prefix}} = $suffix . '-' . $suffix_count{$suffix};
}

my $final_seq;
my ($current, $next, $correct_seq);
$current = $ordered_sequences[0] . '-1';
for (my $j = 0; $j < $length; $j++) {
  $next = $hash{$current};
  $correct_seq = substr($next, 0, 1);
  $final_seq .= $correct_seq;
  $current = $next;
}
print "$final_seq final_seq\n";
