use strict;
use Getopt::Long;

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

my $seq1 = $chars[0];
my $seq2 = $chars[1];
my $seq3 = $chars[2];
my @seq1 = split('', $seq1);
my @seq2 = split('', $seq2);
my @seq3 = split('', $seq3);

my $length1 = scalar(@seq1);
my $length2 = scalar(@seq2);
my $length3 = scalar(@seq3);
my @scores;

$scores[0][0][0] = 0;
for (my $i = 1; $i <= $length1; $i++) {
  $scores[$i][0][0] = 0;
  $scores[$i][1][0] = 0;
  $scores[$i][0][1] = 0;
}
for (my $j = 1; $j <= $length2; $j++) {
  $scores[0][$j][0] = 0;
  $scores[0][$j][1] = 0;
}
for (my $k = 1; $k <= $length3; $k++) {
  $scores[0][0][$k] = 0;
}

my $max_score = 0;
my @backtrack;
#$backtrack[0][0][0] = 2;
#$backtrack[0][1] = 0;
#$backtrack[1][0] = 1;
my $top_score = 0;
for (my $i = 1; $i <= $length1; $i++) {
  for (my $j = 1; $j <= $length2; $j++) {
    for (my $k = 1; $k <= $length3; $k++) {
      if ($seq1[$i-1] eq $seq2[$j-1]) {
        if ($seq2[$j-1] eq $seq3[$k-1]) {
print "Matching sequences " . $seq1[$i-1] . " and " . $seq2[$j-1]  . " with " . $seq3[$k-1] . "\n";
          $top_score++;
          $max_score = 1;
        } else {
          $max_score = 0;
        }
      } elsif ($seq2[$j-1] eq $seq3[$k-1]) {
        $max_score = 0;
      } else {
        $max_score = 0;
      }
      $scores[$i][$j][$k] = max($scores[$i-1][$j][$k], $scores[$i][$j-1][$k], $scores[$i][$j][$k-1], $scores[$i-1][$j-1][$k], $scores[$i-1][$j][$k-1], $scores[$i][$j-1][$k-1], $scores[$i-1][$j-1][$k-1] + $max_score);
      if ($scores[$i][$j][$k] == $scores[$i-1][$j][$k]) {
        $backtrack[$i][$j][$k] = 0;
      } elsif ($scores[$i][$j][$k] == $scores[$i][$j-1][$k]) {
        $backtrack[$i][$j][$k] = 1;
      } elsif ($scores[$i][$j][$k] == $scores[$i][$j][$k-1]) {
        $backtrack[$i][$j][$k] = 2;
      } elsif ($scores[$i][$j][$k] == $scores[$i-1][$j-1][$k]) {
        $backtrack[$i][$j][$k] = 3;
      } elsif ($scores[$i][$j][$k] == $scores[$i-1][$j][$k-1]) {
        $backtrack[$i][$j][$k] = 4;
      } elsif ($scores[$i][$j][$k] == $scores[$i][$j-1][$k-1]) {
        $backtrack[$i][$j][$k] = 5;
      } elsif ($scores[$i][$j][$k] == $scores[$i-1][$j-1][$k-1] + $max_score) {
        $backtrack[$i][$j][$k] = 6;
      }
    }
  }
}

print "Final score is " . $scores[$length1][$length2][$length3] . "\n";
print "Found top score $top_score\n";
my $align1 = '';
my $align2 = '';
my $align3 = '';
my $backtrack = backtrack(\@backtrack, \@seq1, \@seq2, \@seq3, $length1, $length2, $length3, $align1, $align2, $align3);


sub backtrack {
  my $backtrack = shift;
  my $seq1 = shift;
  my $seq2 = shift;
  my $seq3 = shift;
  my $length1 = shift;
  my $length2 = shift;
  my $length3 = shift;
  my $align1 = shift;
  my $align2 = shift;
  my $align3 = shift;
  my @seq1 = @$seq1;
  my @seq2 = @$seq2;
  my @seq3 = @$seq3;
  if ($length1 == 0 || $length2 == 0 || $length3 == 0) {
#    if ($length1 > 0 && $length2 == 0) {
#      $align1 =  $seq1[$length1-1] . $align1;
#      $align2 = '-' . $align2;
#    } elsif ($length1 == 0 && $length2 > 0) {
#      $align1 = '-' . $align1;
#      $align2 = $seq2[$length2-1] . $align2;
#    }
    print $align1 . "\n";
    print $align2 . "\n";
    print $align3 . "\n";
    return;
  }
  if ($backtrack->[$length1]->[$length2]->[$length3] == 0) {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = '-' . $align2;
    $align3 = '-' . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1 - 1, $length2, $length3, $align1, $align2, $align3);
  } elsif ($backtrack->[$length1]->[$length2]->[$length3] == 1) {
    $align1 = '-' . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    $align3 = '-' . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1, $length2 - 1, $length3, $align1, $align2, $align3);
  } elsif ($backtrack->[$length1]->[$length2]->[$length3] == 2) {
    $align1 = '-' . $align1;
    $align2 = '-' . $align2;
    $align3 = $seq3[$length3-1] . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1, $length2, $length3 - 1, $align1, $align2, $align3);
  } elsif ($backtrack->[$length1]->[$length2]->[$length3] == 3) {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    $align3 = '-' . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1 - 1, $length2 - 1, $length3, $align1, $align2, $align3);
  } elsif ($backtrack->[$length1]->[$length2]->[$length3] == 4) {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = '-' . $align2;
    $align3 = $seq3[$length3-1] . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1 - 1, $length2, $length3 - 1, $align1, $align2, $align3);
  } elsif ($backtrack->[$length1]->[$length2]->[$length3] == 5) {
    $align1 = '-' . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    $align3 = $seq3[$length3-1] . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1, $length2 - 1, $length3 - 1, $align1, $align2, $align3);
  } else {
    $align1 = $seq1[$length1-1] . $align1;
    $align2 = $seq2[$length2-1] . $align2;
    $align3 = $seq3[$length3-1] . $align3;
    backtrack($backtrack, $seq1, $seq2, $seq3, $length1 - 1, $length2 - 1, $length3 - 1, $align1, $align2, $align3);
  }
}

sub max {
  my @scores = @_;
  my @ordered_scores = sort { $b <=> $a } @scores;
  my $score = $ordered_scores[0] || 0;
  return $score;
}
