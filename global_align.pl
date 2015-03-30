use strict;
use Getopt::Long;

my $file;
my $matrix;

&GetOptions(
'file:s'      => \$file,
'matrix:s'    => \$matrix ) ;


open ( FILE, $file ) || die " cant read $file \n" ;
open ( MATRIX, $matrix ) || die " cant read $matrix \n" ;


my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push (@chars, $line);
}

my @entries;
my @matrix;
my $i = 0;
my $length;
my @peptides = ('A', 'C', 'D', 'E', 'F', 'G', 'H', 'I', 'K', 'L', 'M', 'N', 'P', 'Q', 'R', 'S', 'T', 'V', 'W', 'Y');
my %position_hash;
my $position = 0;
foreach my $peptide (@peptides) {
  $position_hash{$peptide} = $position;
  $position++;
}
while (my $entry = <MATRIX>) {
  chomp($entry);
  @entries = split(' ', $entry);
  $length = scalar(@entries);
  foreach (my $j = 0; $j < $length; $j++) {
    $matrix[$i][$j] = $entries[$j];
  }
  $i++;
}

my @seq1 = split('', $chars[0]);
my @seq2 = split('', $chars[1]);

my $length1 = scalar(@seq1);
my $length2 = scalar(@seq2);
my @scores;

$scores[0][0] = 0;
for (my $i = 1; $i <= $length1; $i++) {
  $scores[$i][0] = -5 * $i;
}
for (my $j = 1; $j <= $length2; $j++) {
  $scores[0][$j] = -5 * $j;
}

my $max_score = 0;
my @backtrack;
$backtrack[0][0] = 2;
$backtrack[0][1] = 0;
$backtrack[1][0] = 1;
my ($position_i, $position_j);
for (my $i = 1; $i <= $length1; $i++) {
  for (my $j = 1; $j <= $length2; $j++) {
    $position_i = $position_hash{$seq1[$i-1]};
    $position_j = $position_hash{$seq2[$j-1]};
    $max_score = $scores[$i-1][$j-1] + $matrix[$position_i][$position_j];
    $scores[$i][$j] = max($scores[$i-1][$j] - 5, $scores[$i][$j-1] - 5, $max_score);
    if ($scores[$i][$j] == $scores[$i-1][$j] - 5) {
      $backtrack[$i][$j] = 0;
    } elsif ($scores[$i][$j] == $scores[$i][$j-1] - 5) {
      $backtrack[$i][$j] = 1;
    } elsif ($scores[$i][$j] == $max_score) {
#print "Mismatch accepted for " . $seq1[$i-1] . " and " . $seq2[$j-1] . "\n";
      $backtrack[$i][$j] = 2;
    }
  }
}

print "Found maximum score " . $scores[$length1][$length2] . "\n";
my $align1 = '';
my $align2 = '';
my $backtrack = backtrack(\@backtrack, \@seq1, \@seq2, $length1, $length2, $align1, $align2);


sub backtrack {
  my $backtrack = shift;
  my $seq1 = shift;
  my $seq2 = shift;
  my $length1 = shift;
  my $length2 = shift;
  my $align1 = shift;
  my $align2 = shift;
  my @seq1 = @$seq1;
  my @seq2 = @$seq2;
  if ($length1 == 0 || $length2 == 0) {
    if ($length1 > 0 && $length2 == 0) {
      $align1 =  $seq1[$length1-1] . $align1;
      $align2 = '-' . $align2;
    } elsif ($length1 == 0 && $length2 > 0) {
      $align1 = '-' . $align1;
      $align2 = $seq2[$length2-1] . $align2;
    }
    print $align1 . "\n";
    print $align2 . "\n";
    return;
  }
  if ($backtrack->[$length1]->[$length2] == 0) {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = '-' . $align2;
    backtrack($backtrack, $seq1, $seq2, $length1 - 1, $length2, $align1, $align2);
  } elsif ($backtrack->[$length1]->[$length2] == 1) {
    $align1 = '-' . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    backtrack($backtrack, $seq1, $seq2, $length1, $length2 - 1, $align1, $align2);
  } else {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    backtrack($backtrack, $seq1, $seq2, $length1 - 1, $length2 - 1, $align1, $align2);
  }
}

sub max {
  my @scores = @_;
  my @ordered_scores = sort { $b <=> $a } @scores;
  return $ordered_scores[0];
}
