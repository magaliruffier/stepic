use strict;
use Getopt::Long;

my $file;

&GetOptions(
'file:s'      => \$file);


open ( FILE, $file ) || die " cant read $file \n" ;


my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push @chars, $line;
}


my $genome = $chars[0];
my $k = $chars[1];

my @substrs = map {\substr $genome, $_} 0 .. length($genome) - 1;

my @sorted = sort { $$a cmp $$b } @substrs;
my $length = length($genome);
my $count = 0;
foreach my $s (@sorted) {
  if (($length - length($$s)) % $k == 0) {
    print "$count,";
    print  $length - length($$s) . "\n";
  }
  $count++;
}

