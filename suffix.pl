use strict;
use Getopt::Long;
use SuffixTree;

my $file;
my $matrix;

&GetOptions(
'file:s'      => \$file,
'matrix:s'    => \$matrix ) ;


open ( FILE, $file ) || die " cant read $file \n" ;


my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push (@chars, $line);
}

my $text = $chars[0];
my $t = SuffixTree->new($text);
$t->dump();
