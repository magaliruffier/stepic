#!/usr/local/ensembl/bin/perl -w



use strict;
use Getopt::Long;

my $file;
&GetOptions('file:s'      => \$file ) ;
open ( FILE, $file ) || die " cant read $file \n" ;


my @coins;
my $money = 19624;
while (my $line = <FILE>) {
  chomp($line);
  @coins = split(',', $line);
}

my $coins = scalar(@coins);
my @mins;
$mins[0] = 0;

for (my $m = 1; $m <= $money; $m++) {
  $mins[$m] = $money;
  for (my $i = 0; $i < $coins; $i++) {
    if ($m >= $coins[$i]) {
#print "Looking at $m and coin $i " . $coins[$i] . ", comparing " . $mins[$m-$coins[$i]] . " with " . $mins[$m] . "\n";
      if ($mins[$m-$coins[$i]] + 1 <= $mins[$m]) {
        $mins[$m] = $mins[$m-$coins[$i]] + 1;
#print "Smaller, now have " . $mins[$m] . " for $m\n";
      }
    }
  }
}

#foreach my $m (@mins) {
#print $m . " ";
#}
#print "\n";
print $mins[$money]. " found my minimum change\n";


