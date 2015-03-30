ese strict;
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
my $length = length($foo);


my @substrs = map {\substr $foo, $_} 0 .. length($foo) - 1;
#print "What is @substrs\n";
#print "Created " . scalar(@substrs) . " list using $foo\n";

my @ordered = @{\@substrs};

mergesort(\@ordered);
#print "Have now run mergesort, got @ordered\n";

my @results = map {$_->[1] } map { [$_, length($_) ] } @ordered;
#print "Mapped strings to length for @results\n";

#print "About to run through @results with $length fetched from $foo\n";
while (my $elt = shift @results) {
  print $length - $elt . ", ";
}

print "\n";



sub mergesort {
    mergesort_recurse ($_[0], 0, $#{ $_[0] });
}

sub mergesort_recurse {
    my ( $array, $first, $last ) = @_;

    if ( $last > $first ) {
        local $^W = 0;               # Silence deep recursion warning.
        my $middle = int(( $last + $first ) / 2);

        mergesort_recurse( $array, $first,       $middle );
        mergesort_recurse( $array, $middle + 1,  $last   );
        merge( $array, $first, $middle, $last );
#print "Merging into \n" ;
#foreach my $elt (@$array) { print $$elt . " array\n"; }
    }
}

sub merge {
    my ( $array, $first, $middle, $last ) = @_;

    my @work;

    my $n = $last - $first + 1;

    # Initialize work with relevant elements from the array.
    for ( my $i = $first, my $j = 0; $i <= $last; ) {
        $work[ $j++ ] = ${$array->[ $i++ ]};
    }
    $middle = int(($first + $last) / 2) if $middle > $last;

    my $n1 = $middle - $first + 1;    # The size of the 1st half.
#print "First half $n1 is now @work with $last and $first\n";
#for (my $index = 0; $index < $length; $index++) { print ${$array->[$index]} . ", "; }
#print "\n";

    for ( my $i = $first, my $j = 0, my $k = $n1; $i <= $last; $i++ ) {
#print "Updated " . ${$array->[$i]} . " with index $i to ";
        ${$array->[ $i ]} =
            $j < $n1 &&
              ( $k == $n || $work[ $j ] lt $work[ $k ] ) ?
                $work[ $j++ ] :
                $work[ $k++ ];
#print ${$array->[$i]} . " and about to change " . ${$array->[$i+1]} . "\n";
    }
#print "After remapping\n";
#for (my $index = 0; $index < $length; $index++) { print ${$array->[$index]} . ", "; }
#print "\n";
#foreach my $elt (@$array) { print $$elt . "\n"; }
}
