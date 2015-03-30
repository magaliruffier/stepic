use strict;
use Getopt::Long;

my $file;

&GetOptions(
'file:s'      => \$file);


open ( FILE, $file ) || die " cant read $file \n" ;


my $foo;
while (my $line = <FILE>) {
  chomp($line);
  $foo .= $line;
}
close FILE;


my @substrs = map {\substr $foo, $_} 0 .. length($foo) - 1;

my @sorted = map { $_->[1] } sort { $a->[0] cmp $b->[0] } map { [$$_, length($$_)] } @substrs;
#print "Sorted list is @sorted\n";

my $length = length($foo);
while (my $s = shift @sorted) {
  print $length - $s . ", ";
}
print "\n";

