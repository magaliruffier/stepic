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



my @chars;
my $text_length = 16;
my ($prefix, $suffix, $length, $kmer, $offset);
my %hash;
my @kmers = combinations($text_length);
my $seq_count = 0;
my %prefix_hash;
my @suffix;
my $nb_values = 0;
foreach my $kmer (@kmers) {
  $prefix = substr($kmer, 0, $text_length - 1);
  $suffix = substr($kmer, 1, $text_length);
  push @{ $prefix_hash{$prefix} }, $suffix;
}

my $start = substr($kmers[0], 0, $text_length-1);
my @keys = keys %prefix_hash;
my $key = $start;
my @cycle = ($key);
my $value;
my $true = 1;
my %used_keys;
while ($true) {
  $value = $prefix_hash{$key}[0];
  $used_keys{$key}++;
  push @cycle, $value;
  shift @{ $prefix_hash{$key}};
  if (!$prefix_hash{$key}[0]) {
    delete $prefix_hash{$key};
  }
  $key = $value;
  if (!$prefix_hash{$key}) { $true = 0; }
}


my @cycle2;
@keys = keys %prefix_hash;
my $nb = 0;
while(@keys) {
  foreach my $c (@cycle) {
    if ($prefix_hash{$c}) {
      $start = $c;
      last;
    }
  }
  $key = $start;
  @cycle2 = ($key);
  $nb++;
  $true = 1;
  while ($true) {
    $used_keys{$key}++;
    $value = $prefix_hash{$key}[0];
    push @cycle2, $value;
    shift @{ $prefix_hash{$key}};
    if (!$prefix_hash{$key}[0]) {
      delete $prefix_hash{$key};
    }
    $key = $value;
    if (!$prefix_hash{$key}) { $true = 0; }
  }
  @keys = keys %prefix_hash;
  @cycle = @{ merge(\@cycle, \@cycle2) };
}

pop @cycle;
foreach my $node (@cycle) {
  print substr($node, 0, 1);
}
print "\n";


sub combinations {
  my $number = shift;
  my @chars = ('0', '1');

  $number --; # decrement $number, so that you will eventually exit
               # from this recursive subroutine (once $number == 0)
  if ($number) { # true as long as $number != 0 and $number not undef
    my @result;
    foreach my $char (@chars) {
      my @intermediate_list = map { $char . $_ } combinations($number, @chars);
      push @result, @intermediate_list;
    }
    return @result; # the current concatenation result will be used for creation of
                      # @intermediate_list in the 'subroutine instance' that called 'combinations'
  }
  else {
    return @chars;
  }
}
#  my @result = ('0000', '0001', '0010', '0011', '0100',
#    '0101', '0110', '0111', '1000', '1001', '1010',
#    '1011', '1100', '1101', '1110', '1111');
#  return \@result;
#}

sub merge {
  my $cycle = shift;
  my $cycle2 = shift;
  my @cycle = @$cycle;
  my @cycle2 = @$cycle2;
  my $length = scalar(@cycle);
  my $length2 = scalar(@cycle2);
  my $start = $cycle2[0];
  my $end;
  for (my $i = 0; $i < $length; $i++) {
    if ($cycle[$i] eq $start) {
      $end = $i;
      last;
    }
  }
  my @result_cycle = @cycle[0..$end-1];
  push @result_cycle, @cycle2;
  push @result_cycle, @cycle[$end+1..$length-1];
  return \@result_cycle;
}
