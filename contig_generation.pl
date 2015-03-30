#@i!/usr/local/ensembl/bin/perl -w



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
&GetOptions('file:s'      => \$file ) ;
open ( FILE, $file ) || die " cant read $file \n" ;


my ($length);
my %hash;
my @kmers;
my $seq_count = 0;
my ($prefix, $suffix, $pre_overlap, $suf_overlap);
my %prefix_hash;
my %suffix_hash;
my (%prefix, %suffix);
while (my $line = <FILE>) {
  chomp($line);
  $length = length($line);
  $prefix = substr($line, 0, $length - 1);
  $suffix = substr($line, 1, $length);
  push @{ $prefix_hash{$prefix} }, $suffix;
  push @{ $suffix_hash{$suffix} }, $prefix;
  $prefix{$prefix} = $line;
  $suffix{$suffix} = $line;
  push @kmers, $line;
}

my %vertix_prefix;
my @values;
foreach my $key (sort {$a cmp $b} keys %prefix_hash) {
  @values = @{ $prefix_hash{$key} };
  $vertix_prefix{$key} = scalar(@values);
}

my %vertix_suffix;
foreach my $key (sort {$a cmp $b} keys %suffix_hash) {
  @values = @{ $suffix_hash{$key} };
  $vertix_suffix{$key} = scalar(@values);
}

my $true;
my @results;
my (%newp_hash, %news_hash, %start_hash);
foreach my $k (@kmers) {
  $suffix = substr($k, 1, $length);
  $prefix = substr($k, 0, $length - 1);
#print "Considering $k with " . $vertix_prefix{$prefix} . " suffix and " . $vertix_suffix{$suffix} . " counts for $prefix and $suffix as well as " . $vertix_suffix{$prefix} . " prefix count and " . $vertix_prefix{$suffix} . "\n";
  if (!$vertix_prefix{$suffix}) {
    if ($vertix_suffix{$suffix} == 1) {
#print "Adding as an end\n";
      $start_hash{$k} = $prefix;
      $news_hash{$k} = $suffix;
    }
  } elsif (!$vertix_suffix{$prefix}) {
    if ($vertix_prefix{$prefix} == 1) {
#print "Adding as a start\n";
      $start_hash{$k} = $prefix;
      $news_hash{$k} = $suffix;
    }
  } elsif ( $vertix_suffix{$suffix} == 1 && $vertix_prefix{$suffix} == 1 ) {
    if ( $vertix_prefix{$prefix} == 1 && $vertix_suffix{$prefix} == 1 ) {
#print "Adding as a connection\n";
      $news_hash{$k} = $suffix;
      $hash{$k} = $prefix;
    } else {
#print "Adding as another start\n";
      $start_hash{$k} = $prefix;
      $news_hash{$k} = $suffix;
    }
  } elsif ($vertix_prefix{$prefix} == 1 && $vertix_suffix{$prefix} == 1) {
    if ($vertix_prefix{$suffix} == 1 && $vertix_suffix{$suffix} == 1) {
#print "Adding as another connection\n";
      $news_hash{$k} = $suffix;
      $hash{$k} = $prefix;
     } else {
#print "Adding as another end\n";
       
     }
#  } elsif ( $vertix_suffix{$suffix} == 1) {
#    if ( $vertix_prefix{$suffix} == 1) {
#      $start_hash{$k} = $prefix;
#      $news_hash{$k} = $suffix;
#      $hash{$k} = $prefix;
#      if  ($vertix_prefix{$prefix} > 1 && $vertix_suffix{$prefix} > 1) {
#        $start_hash{$k} = $prefix;
#      }
#    }
#  } elsif ( $vertix_prefix{$prefix} == 1) {
#    if ( $vertix_suffix{$prefix} == 1) {
#      $news_hash{$k} = $suffix;
#    }
  } else {
#print "Could not find it any where\n";
    push @results, $k;
  }
}

my @keys = keys %start_hash;
#print scalar(@results)  . " results found so far and " . scalar(@keys) . " left to process\n";
my @considered = keys %news_hash;
#print "Have " .scalar(@considered) . " strings to add somewhere\n";
my $key = $keys[0];
my $string;
my ($start, $end, $value);
while (@keys) {
  $suffix = $news_hash{$key};
  $string = $key;
  while ($suffix) {
    $start = $prefix{$suffix};
    $end = $suffix{$suffix};
#print "Found $suffix, adding " . $news_hash{$key} . " for $key and $start\n";
    $string .= substr($start, $length - 1, 1);
    delete $start_hash{$key};
    $key = $start;
    $suffix = $news_hash{$key};
  }
  push @results, $string;
  @keys = keys %start_hash;
  $key = $keys[0];
}

foreach my $r (sort {$a cmp $b} @results) {
  print $r . "\n";
}


