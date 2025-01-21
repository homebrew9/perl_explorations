#!perl -w
# A short program to create a B-Tree to store bit-combinations and then print
# them to display all combinations of n-digit binary numbers.
# By: prat
# On: 29-Jul-2015

my $first_invocation = 1;
my %btree = ();
my $str;
$btree{9} = [
                 {
                         0 => [
                                   {
                                           0 => [
                                                     {},
                                                     {}
                                                ]
                                   },
                                   {
                                           1 => [
                                                     {},
                                                     {}
                                                ]
                                   }
                              ]
                 },
                 {
                         1 => [
                                   {
                                           0 => [
                                                     {},
                                                     {}
                                                ]
                                   },
                                   {
                                           1 => [
                                                     {},
                                                     {}
                                                ]
                                   }
                              ]
                 }
            ];

# Subroutine section
sub treeprint {
    my $href = shift;
    if ( keys %{$href} ) {
        my $key = (keys %{$href})[0];
        if ($first_invocation) {
            $first_invocation = 0;
        } else {
            #printf("==>[%d]<==\n", $key);
            $str .= $key;
        }
        treeprint( $href->{$key}->[0] );
        treeprint( $href->{$key}->[1] );
    }
    printf("[%s]\n", $str);
    $str =~ s/.$//;
}

# Main section
treeprint(\%btree);

