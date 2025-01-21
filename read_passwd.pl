#!/usr/bin/perl
#===============================================================================
# Code is from the following link:
# https://stackoverflow.com/questions/701078/how-can-i-enter-a-password-using-perl-and-replace-the-characters-with
#===============================================================================
use strict;
use warnings;
use Term::ReadKey;

my $key = 0;
my $password = "";

# Added a newline at the end of the prompt since otherwise it prints the prompt
# and the final line after I've entered the password in Windows 7. I believe it
# works correctly without the final newline in Debian Linux. - prat, 1/9/19
print "\nPlease input your password below:\n";

# Start reading the keys
ReadMode(4); #Disable the control keys

# It does not work in Windows; the ASCII value of the Enter or Return key
# is 13 (CR = Carriage Return). Keep it 13 for Windows. This comment is
# from the same StackOverflow link above.  - prat, 1/9/19
while(ord($key = ReadKey(0)) != 13)
#while(ord($key = ReadKey(0)) != 10)
# This will continue until the Enter key is pressed (decimal value of 10)
{
    # For all value of ord($key) see http://www.asciitable.com/
    if(ord($key) == 127 || ord($key) == 8) {
        # DEL/Backspace was pressed
        #1. Remove the last char from the password
        chop($password);
        #2 move the cursor back by one, print a blank character, move the cursor back by one
        # I removed this as this is unnecessarily removing characters from the prompt. - prat, 2/21/18
        #print "\b \b";
    } elsif(ord($key) < 32) {
        # Do nothing with these control characters
    } else {
        $password = $password.$key;
        # Also removed the following so that the ascii value is not printed. - prat, 2/21/18
        #print "*(".ord($key).")";
    }
}
ReadMode(0); #Reset the terminal once we are done
print "\nYour super secret password is: $password\n";

