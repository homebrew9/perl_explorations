#!/usr/bin/perl
# ===================================================================================
# Name : graph_traversal.pl
# Desc : A Perl program to perform hierarchical graph traversal the way Oracle's
#      : "connect by ... prior" SQL does. This program handles cycles in the data.
#      : This programs uses references and recursive subroutines.
# Ex.  :     perl graph_traversal.pl -f hr_emp_hierarchy.txt -d:
#      :     perl graph_traversal.pl -f edge_list.txt
# By   : prat
# On   : 6-Mar-2015
# ===================================================================================
use strict;
use Getopt::Std;
use Data::Dumper;

my %opts;         # hash for storing arguments
my $data_file;    # data file containing the edge list
my $delimiter;    # the optional delimiter character

my %tree;
my $insert_count;
my $line_nbr;
my $edge_found;
my $self_reference;
my @stack = ();
my @traversed_paths = ();

my $node_ptr = "";
my @traversed_array = ();
my $max_node_length = 1;
my $fmt_data;
my @header = (
               [ "Node",      "s", "-",  1 ],
               [ "Level",     "d", "",   8 ],
               [ "Is_Root",   "d", "",  10 ],
               [ "Root_Node", "s", "-",  1 ],
               [ "Is_Leaf",   "d", "",  10 ],
               [ "Is_Cycle",  "d", "",  11 ],
               [ "Path",      "s", "-", 60 ]
             );

# ==============================================================================
# SUBROUTINE SECTION
# ==============================================================================
sub show_usage_if_needed {
    if ($#ARGV == -1) {
        print "\n";
        print "Usage: perl graph_traversal.pl -f <data_file> [-d <character>]\n";
        print "       <data_file> = file that has list of edges\n";
        print "       <character> = optional delimiter; if omitted, blank space is used\n";
        exit;
    }
}

sub process_args {
    getopts("f:d:", \%opts);
    $data_file = $opts{"f"};
    $delimiter = $opts{"d"};
    if ($data_file eq "") {
        print "Data file is mandatory!\n";
        exit;
    }
}

# Check if the child node is present in the currently traversed stack 
sub child_node_found_in_stack {
    my ($arr_ref, $child_node) = @_;
    $node_ptr = "";
    my $x = -1;
    my $item;
    do {
        $x++;
        $item = $arr_ref->[$x];
        $node_ptr = ($x == 0) ? $tree{$item} : $node_ptr->{$item};
    }
    until ($item eq $child_node or $x == $#{$arr_ref});
    if ($item eq $child_node) {
        # CHILD NODE EXISTS IN TRAVERSAL STACK!!!
        return 1;
    }
    return 0;
}

# Check if the child node is present as the last element in any of traversed paths arrays
sub child_node_found_in_traversed_paths {
    my $child_node = shift;
    my $child_node_found = 0;
    @traversed_array = ();
    foreach my $i (@traversed_paths) {
        @traversed_array = @{$i};
        if ($child_node eq $traversed_array[-1]) {
            $child_node_found = 1;
            last;
        }
    }
    if ($child_node_found) {
        # CHILD NODE EXISTS IN TRAVERSED ARRAY => @{traversed_array}  !!!
        return 1;
    }
    return 0;
}

sub add_back_reference {
    my ($pt, $cd, $trv_aref, $hash_ref) = (shift, shift, shift, shift);
    my $ptr;
    foreach my $j ( @{$trv_aref} ) {
        $ptr = (defined $ptr) ? $ptr->{$j} : $tree{$j};
    }
    if (defined $hash_ref) {
        # Branch or leaf node
        $hash_ref->{$pt} = { $cd => $ptr };
    } else {
        # Root node
        $tree{$pt} = { $cd => $ptr };
    }
}


sub generate_tree {
    my ($href, $prnt, $chld) = (shift, shift, shift);
    $insert_count = shift;
    $edge_found = shift;
    $self_reference = shift;
    my $aref = shift;
    if ($prnt eq $chld) {
        $self_reference = 1;
        printf("Skipping the self-reference at line %5d : %s - %s\n",$line_nbr,$prnt,$chld);
        return;
    }
    foreach my $k ( keys %{$href} ) {
        push @{$aref}, $k ;
        if ($k eq $prnt) {
            my @arr = grep {/$chld/} ( keys %{ $href->{$prnt} } );
            if ( $#arr >= 0 ) {
                $edge_found = 1;
                printf("Skipping the duplicate edge at line %5d : %s - %s\n",$line_nbr,$prnt,$chld);
            } else {
                # Traversal stack = @{ $aref }
                # Traversed paths = @traversed_paths
                if ( child_node_found_in_stack($aref, $chld) ) {
                    $href->{$prnt} = { $chld => $node_ptr };
                } elsif ( child_node_found_in_traversed_paths($chld) ) {
                    # Child node was found in traversed paths array; set the back reference
                    add_back_reference($prnt, $chld, \@traversed_array, $href);
                } else {
                    # Otherwise add a new child node.
                    $href->{$prnt}->{$chld} = {};
                }
                # Push the traversal stack in the traversed_paths array
                my @current_stack = @{$aref};
                push @traversed_paths, \@current_stack;
                $insert_count++;
            }
            pop @{$aref} ;
            next;
        }
        generate_tree($href->{$k}, $prnt, $chld, $insert_count, $edge_found, $self_reference, $aref);
    }
    pop @{$aref} ;
}

sub generate_graph_from_file {
    my $delimiter_pat = quotemeta($delimiter);
    open(FH, "<", $data_file) or die "Can't open $data_file: $!";
    while (<FH>){
        next if (/^#/ or /^\s*$/);
        $line_nbr = $.;
        chomp;
        my ($parent, $child) = (not $delimiter) ? split /\s+/ : split $delimiter_pat;

        # $header[3]->[0] = "Root_Node". The  max edge length should at least be the length of this column header.
        $max_node_length = (sort {$b <=> $a} (length($parent), length($child), $max_node_length), length($header[3]->[0]))[0];

        generate_tree(\%tree, $parent, $child, 0, 0, 0, \@stack);
        if (not $self_reference and not $edge_found and $insert_count == 0) {
            # Traversal stack = @stack
            # Traversed paths = @traversed_paths
            # If child node was found in traversed paths array, then set the back reference
            if ( child_node_found_in_traversed_paths($child) ) {
                add_back_reference($parent, $child, \@traversed_array);
            } else {
                # Otherwise add a new child node.
                $tree{$parent} = { $child => {} };
            }
            # Push the parent node in the traversed_paths array
            push @traversed_paths, [ $parent ];
        }
        $insert_count = 0;
        $edge_found = 0;
        @stack = ();
    }
    close(FH) or die "Can't close $data_file: $!";
}

sub line {
    my($char, $len) = @_;
    return $char x $len;
}

sub fmt_col_hdr {
    my ($str, $len) = @_;
    my $left = int(($len - length($str))/2);
    my $right = $len - length($str) - $left;
    return line(" ", $left).$str.line(" ",$right);
}

sub print_header {
    # Set the lengths of "Node" and "Root_Node" to max node length and "Path" to a multiple of that
    $header[0]->[-1] = $max_node_length;
    $header[3]->[-1] = $max_node_length;
    $header[6]->[-1] = 4*$max_node_length;

    my @fmt_lines = map{ line("-", $header[$_]->[-1]) } (0..$#header);
    my $fmt_hdr = join "+", map{ my $x = "%".$header[$_]->[-1]."s" ; $x } (0..$#header);
    my $fmt_cols = join "|", map{ fmt_col_hdr($header[$_]->[0], $header[$_]->[-1]) } (0..$#header);
    $fmt_data = join "|", map{ my $x = "%".$header[$_]->[2].$header[$_]->[-1].$header[$_]->[1] ; $x } (0..$#header);

    printf("${fmt_hdr}\n", @fmt_lines);
    printf("%s\n", $fmt_cols);
    printf("${fmt_hdr}\n", @fmt_lines);
}

sub traverse_tree {
    my ($href, $level, $root_node, $aref) = (shift, shift, shift, shift);
    # Traversal stack = @{ $aref }
    foreach my $k ( keys %{$href} ) {
        if (grep {$_ eq $k} @{$aref}) {
            # We found a loop; time to escape from recursion now!
            last;
        }
        push(@{$aref}, $k);
        my $is_root = $level == 1 ? 1 : 0;
        if ($level == 1) { $root_node = $k }
        my $is_leaf = (! keys %{ $href->{$k} }) ? 1 : 0;
        my $is_cycle = 0;

        # If any of the keys in the hash referenced by $k exists in the traversal stack @{$aref}
        # then we should set the values of $is_leaf and $is_cycle to 1 each. Notice that we are
        # looking "forward" one level to determine the leaf/cycle values since that is what Oracle
        # displays as well. The actual "escape" on account of loop detection will be done in the
        # next recursive call, and will be done at the "grep" right below "foreach $k".
        foreach my $j ( keys %{ $href->{$k} } ) {
            if ( grep { $_ eq $j } @{$aref} ) {
                # set leaf/cycle values
                $is_cycle = 1;
                $is_leaf = 1;
                # and we're done comparing; get out of this foreach loop
                last;
            }
        }
        printf("${fmt_data}\n", $k, $level, $is_root, $root_node, $is_leaf, $is_cycle, join("->", @{$aref}));
        traverse_tree($href->{$k}, ($level+1), $root_node, $aref);
    }
    $level--;
    pop(@{$aref});
}

sub traverse_and_print_graph {
    @stack = ();
    traverse_tree(\%tree, 1, "", \@stack);
}

# ==============================================================================
# MAIN SECTION
# ==============================================================================
show_usage_if_needed;
process_args;
generate_graph_from_file;
print_header;
traverse_and_print_graph;

