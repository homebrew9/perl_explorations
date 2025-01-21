#!perl
# ------------------------------------------------------------------------------
# From: http://www.perlmonks.org/?node_id=886306
# Notes by prat:
# (1)  Unfortunately, Term::ReakKey does *not* ship with standard Perl!!
# (2)  Do not run this in Cygwin Perl unless you want an infinite loop and a
#      "Ctrl+Alt+Del -> Kill process" as the only way of exiting!!
# On: 1/4/2017
# ------------------------------------------------------------------------------

my $pword = get_pword( "Enter password" );
print "Password is '$pword'\n";

sub get_pword {
    use Term::ReadKey;

    my ($prompt) = shift; 
    my $pword;
    my $key;
    local $| = 1;  # Turn off STDOUT buffering for immediate response
    print "$prompt: ";
    ReadMode 4;    # Change to Raw Mode, disable Ctrl-C
    while( 1 ) {
        while (not defined ($key = ReadKey(-1))) { }
        if(ord($key) == 13) { # if Enter was pressed...
            print "\n";       # print a newline
            last;             # and get out of here
        }
        print '*';
        $pword .= $key;
    }
    ReadMode 0; # Reset tty mode before exiting. <==IMPORTANT
    return $pword; 
}

