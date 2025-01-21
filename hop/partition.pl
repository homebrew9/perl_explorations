#!perl

# Subroutine section
sub find_share {
    my ($target, $treasures) = @_;

    # Handle trivial cases first
    return [] if $target == 0;
    return if $target < 0 || @$treasures == 0;

    # Now do some real work
    my ($first, @rest) = @$treasures;
    my $solution = find_share($target-$first, \@rest);
    return [$first, @$solution] if $solution;
    return find_share($target, \@rest);
}

# Main section
$retval = find_share(5, [1, 2, 4, 8]);

foreach $item (@$retval) {
    printf("%d\n", $item);
}

print "@$retval";

