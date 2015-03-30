#!/usr/local/ensembl/bin/perl -w



=head1 NAME

  find_unique.pl


=head1 DESCRIPTION

  This script, run on a sequence file, returns the list of n-kmers


=head1 OPTIONS

        -file        name of the sequence file

=head1 EXAMPLE

perl find_kmer.pl -file sequence.fa
=cut



use strict;
use Getopt::Long;

my $file;


#my @list = (-3, 4, 1, 5, -2);
my @list = (1, -3, -6, -5, 2, -4);
my $length = scalar(@list);
my $distance = 0;
my %list = map { abs($list[$_]) => $_ } 0..$#list;


my ($list, $hash_list);
for (my $k = 0; $k < $length; $k++) {
  if (!is_sorted(\@list, $k)) {
#print "Not sorted for " . ($k+1) . ", applying sort reversal\n";
    ($hash_list, $list) = sort_reversal(\%list, \@list, $k);
    %list = %$hash_list;
    @list = @$list;
    $distance++;
  }
  if ($list[$k] == -($k + 1)) {
    $list[$k] = $k + 1;
  }
}

print "2 break distance $distance\n";

sub list_print {
  my $list = shift;
  my @list = @$list;
  my $length = scalar(@list);
  if ($list[0] > 0) {
    print "(+" . $list[0];
  } else {
    print "(" . $list[0];
  }
  for (my $i = 1; $i < $length; $i++) {
    if ($list[$i] > 0) {
      print " +" . $list[$i];
    } else {
      print " " . $list[$i];
    }
  }
  print ")\n";
}

sub is_sorted {
  my $list = shift;
  my $k = shift;
  my @list = @$list;
  if (abs($k+1) == abs($list[$k])) {
    return 1;
  } else {
    return 0;
  }
}

sub sort_reversal {
  my $list = shift;
  my $ordered_list = shift;
  my $k = shift;
  my %list = %$list;
  my @ordered_list = @$ordered_list;
  my $position = $list{abs($k+1)};
#print "Have found $k in $position\n";
  my %final_list = %list;
  my @final_list;
  for (my $i = 0; $i < $k; $i++) {
    push @final_list, $list[$i];
  }
  for (my $i = $position; $i >= $k; $i--) {
    $final_list{abs($list[$i])} = abs($position+$k-$i);
    push @final_list, -1*$list[$i];
  }
  for (my $j = $position+1; $j < $length; $j++) {
    push @final_list, $list[$j];
  }
  return (\%final_list, \@final_list);
}

