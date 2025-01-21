#!/usr/bin/perl
sub fib {
    my ($month) = @_;
#print "Now calculating fib ", $month, "\n";
    if ($month <2) { 1 }
    else {
        fib($month-1) + fib($month-2);
    }
}

my $terms;
if ( $#ARGV < 0 ) {
    print "Enter no. of terms : ";
    $terms = <>;
} else {
    $terms = $ARGV[0];
}

my $total = fib($terms);
print "Total = ", $total, "\n";

