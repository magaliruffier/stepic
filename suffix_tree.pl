use strict;
use Scalar::Util qw(weaken);
no warnings 'recursion';
use Getopt::Long;


my ($s, $k, $txt, $word_nr, $word_map);

use constant INFINITY => 1e5000;
use constant INVALID_BASE => 192;
use constant SLINK    => "\xff\xff";

my @results = ("\$");
sub DrawTree {
    my ($s, $prefix) = @_;
    #print "->", $s->{+SLINK} ? "+" : "*";
    $prefix .= "  ";
    my @keys = sort keys %$s;
    pop @keys if $keys[-1] eq SLINK;
    for (0..$#keys) {
        #print "$prefix|\n$prefix+" if $_;
        my ($k1, $l1, $s1) = @{$s->{$keys[$_]}};
        if ($l1 == INFINITY) {
            my $str = substr($txt, $k1) . "\$";
            #$str =~ s/[^\x00-\x7f]/:/g;
            # printf "--%s(%2d)\$\n", $str, $k1;
            #print "--$str\$\n";
push @results, $str;
        } else {
            #printf "--%s(%2d)", substr($txt, $k1, $l1), $k1;
            #DrawTree($s1, $prefix . ($_ == $#keys ? " " : "|") . " "x(6+$l1));
            my $str = substr($txt, $k1, $l1);
            #$str =~ s/[^\x00-\x7f]/:/g;
push @results, $str;
            #printf "--$str";
            DrawTree($s1,$prefix . ($_ == $#keys ? " " : "|") . " " x (2+$l1));
        }
    }
}


sub Update {
    my $i = shift;
    # (s, (k, i-1)) is the canonical reference pair for the active point
    my $old_root;
    my $chr = substr($txt, $i, 1);
    while (my $r = TestAndSplit($i-$k, $chr)) {
        $r->{$chr} = [$i, INFINITY, $word_map];
        # build suffix-link active-path
        weaken($old_root->{+SLINK} = $r) if $old_root;
        $old_root = $r;
        $s = $s->{+SLINK};
        Canonize($i-$k);
    }
    if (ord($chr) >= INVALID_BASE) {
        vec($word_map,   $word_nr, 1) = 0;
        vec($word_map, ++$word_nr, 1) = 1;
    }
    weaken($old_root->{+SLINK} = $s) if $old_root;
}

sub TestAndSplit {
    my ($l, $t) = @_;
    return !$s->{$t} && $s unless $l;
    my ($k1, $l1, $s1)  = @{$s->{substr($txt, $k, 1)}};
    my $try = substr($txt, $k1 + $l, 1);
    return if $t eq $try;
    # s---->r---->s1
    my %r = ($try => [$k1 +$l, $l1-$l, $s1]);
    $s->{substr($txt, $k1, 1)} = [$k1, $l, \%r];
    return \%r;
}

sub Canonize {
    # s--->...
    my $l = shift || return;

    # find the t_k transition g'(s,(k1,l1))=s' from s
    my ($l1, $s1) = @{$s->{substr($txt, $k, 1)}}[1,2];
    # s--(k1,l1)-->s1
    while ($l1 <= $l) {
        # s--(k1,l1)-->s1--->...
        $k += $l1;  # remove |(k1,l1)| chars from front of (k,l)
        $l -= $l1;
        $s  = $s1;
        # s--(k1,l1)-->s1
        ($l1, $s1) = @{$s->{substr($txt, $k, 1)}}[1,2] if $l;
    }
}

# construct suffix tree for $txt[0..N-1]
sub BuildTree {
    # bottom or _|_
    my %bottom;
    my %root = (SLINK() => \%bottom);
    $s = \%root;

    # Create edges for all chars from bottom to root
    my $end_char = length($txt)-1;
    $bottom{substr($txt, $_, 1)} ||= [$_, 1, \%root] for 0..$end_char;

    $k = 0;
    vec($word_map = "", $word_nr = 0, 1) = 1;

    for (0..$end_char) {
        # follow path from active-point
        Update($_);
        Canonize($_-$k+1);
    }
    # Get rid of bottom link
    delete $root{+SLINK};
    return \%root;
}

my ($best, $to, $want_map);
sub Lcs {
    my ($s, $depth) = @_;
    # Skip leafs
    return $s if !ref($s);
    my $word_map = "";
    for (keys %$s) {
        next if $_ eq SLINK;
        my ($l, $node) = @{$s->{$_}}[1,2];
        $word_map |= Lcs($node, $depth+$l);
    }
    return $word_map if $word_map ne $want_map || $best >= $depth;
    # You may already be a winner !
    # Only do the hard work if we can gain.
    $best = $depth;
    for (keys %$s) {
        next if $_ eq SLINK;
        $to = $s->{$_}[0];
        last;
    }
    return $word_map;
}

sub LongestCommonSubstring {
    my $tree = shift;
    $best = 0;
    $to   = 0;
    Lcs($tree, 0);
    return substr($txt, $to-$best, $best);
}

sub BuildString {
    die "Want at least two strings" if @_ < 2;
    die "Can't currently handle more this many strings" if
        @_ >= 256-INVALID_BASE();
    $txt = "";
    my $chr = INVALID_BASE;
    $want_map = "";
    my $i;
    for (@_) {
        $txt .= $_;
        $txt .= chr($chr++);
        vec($want_map, $i++, 1) = 1;
    }
}

sub CommonSubstring {
    BuildString(@_);
    return LongestCommonSubstring(BuildTree);
}

my $file;
&GetOptions(
'file:s'      => \$file);

open ( FILE, $file ) || die " cant read $file \n" ;

my @chars;
while (my $line = <FILE>) {
  chomp($line);
  push (@chars, $line);
}

#$txt = 'ATAAATG';
$txt = $chars[0];
my $tree = BuildTree();
DrawTree($tree);

my %results_hash;
foreach my $r (@results) {
  $results_hash{$r}++;
}

my @keys = sort { $results_hash{$b} <=> $results_hash{$a} } keys %results_hash;
print $keys[0]  . " longest repeat\n";


print CommonSubstring(@chars);
print "\n";


