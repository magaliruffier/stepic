#!/usr/local/ensembl/bin/perl -w



use strict;
use Getopt::Long;

my ($n_matrix, $m_matrix);
&GetOptions(
'm_matrix:s'      => \$m_matrix,
'n_matrix:s'      => \$n_matrix
 ) ;
open ( M_MATRIX, $m_matrix ) || die " cant read $m_matrix \n" ;
open ( N_MATRIX, $n_matrix ) || die " cant read $n_matrix \n" ;



my $m = 10;
my $n = 15;
my @numbers;
my @m_matrix;
my @n_matrix;
my $length;
my $i = 0;
while (my $line = <M_MATRIX>) {
  chomp($line);
  @numbers = split(' ', $line);
  $length = scalar(@numbers);
  for (my $j = 0; $j < $length; $j++) {
    $m_matrix[$i][$j] = $numbers[$j];
  }
  $i++;
}

$i = 0;
while (my $line = <N_MATRIX>) {
  chomp($line);
  @numbers = split(' ', $line);
  $length = scalar(@numbers);
  for (my $j = 0; $j < $length; $j++) {
    $n_matrix[$i][$j] = $numbers[$j];
  }
  $i++;
}


my @score = (());
$score[0][0] = 0;

for (my $i = 1; $i <= $n; $i++) {
  $score[$i][0] = $score[$i-1][0] + $m_matrix[$i-1][0];
}
for (my $j = 1; $j <= $m; $j++) {
  $score[0][$j] = $score[0][$j-1] + $n_matrix[0][$j-1];
}
for (my $k = 1; $k <= $n; $k++) {
  for (my $l = 1; $l <= $m; $l++) {
#print "For $k and $l, will assess max from " . $score[$k-1][$l] . " and " . $score[$k][$l-1] . " ";
#print "Adding " . $m_matrix[$k-1][$l] . " or " . $n_matrix[$k][$l-1] . " ";
    $score[$k][$l] = max($score[$k-1][$l] + $m_matrix[$k-1][$l], $score[$k][$l-1] + $n_matrix[$k][$l-1]);
#print "with final score " . $score[$k][$l] . "\n";
  }
}

sub max {
  my $first = shift;
  my $last = shift;
  if ($first > $last) {
    return $first;
  } else {
    return $last;
  }
}
print $score[$n][$m] . " best score\n";


