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

my $seq;
my @sequences;

for (my $i = 0; $i < $length; $i++) {
  $seq = substr($string, $i, $length);
  push @sequences, $seq;
}

my @ordered = sort { $a cmp $b} @sequences;

my $bwt = '';
for (my $j = 0; $j < $length; $j++) {
  $bwt .= substr($ordered[$j], $length - 1, 1);
}

print "$bwt\n";



