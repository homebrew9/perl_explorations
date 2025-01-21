#!perl -w
use strict;

my $password;
my $ch;
my $fh;

print "Enter a password : \n";
open($fh, "<-");
while ( defined($ch = getc $fh) ) {
    #$password .= $ch;
    print "[$ch]\n";
}
#print "password = $password\n";
close($fh);

# my $ch;
# my $fh;
# open ($fh, "<-");
# sysread($fh, $ch, 1);
# print "ch = [$ch]\n";
# close($fh);

