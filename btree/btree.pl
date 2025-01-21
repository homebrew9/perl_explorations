#perl -w
use Data::Dumper;
my %btree = ();

# Subroutine section
sub btreeprint {
    my $href = shift;
    my $key = (keys %$href)[0];
    if ( keys %{$href->{$key}->[1]} ) { btreeprint($href->{$key}->[1]) }
    printf("%4d %s\n", $href->{$key}->[0], $key );
    if ( keys %{$href->{$key}->[2]} ) { btreeprint($href->{$key}->[2]) }
}

sub addtree {
    my ($href, $key) = (shift, shift);
    my $k = (keys %$href)[0];
    if ( !keys %$href )  { $href->{$key} = [ 1, {}, {} ] }
    elsif ( $key lt $k ) { addtree( $href->{$k}->[1], $key ) }
    elsif ( $key gt $k ) { addtree( $href->{$k}->[2], $key ) }
    elsif ( $key eq $k ) { $href->{$key}->[0]++ }
}

# Main section
while (<STDIN>) {
    chomp;
    while (/(\w+)/g) { addtree(\%btree, $1) }
}
#print Dumper %btree;
btreeprint(\%btree);

