#!perl
use strict;
use warnings;
use Win32::Console;

run();
sub run {
    my $StdIn = Win32::Console->new(STD_INPUT_HANDLE);
    $StdIn->Mode(ENABLE_PROCESSED_INPUT);
    my $Password = prompt_password($StdIn, "Enter Password: ", '*');
    if ( prompt_echo($StdIn, "\nShow password? [y/n] ") ) {
        print "\nPassword = $Password\n"
    }
    return;
}

sub prompt_password {
    my ($handle, $prompt, $mask) = @_;
    my ($Password);
    local $| = 1;
    print $prompt;
    $handle->Flush;
    while (my $Data = $handle->InputChar(1)) {
        last if "\r" eq $Data;
        if ("\ch" eq $Data ) {
            if ( "" ne chop( $Password )) {
                print "\ch \ch";
            }
            next;
        }
        $Password .= $Data;
        print $mask;
    }
    return $Password;
}

sub prompt_echo {
    my ($handle, $prompt) = @_;
    local $| = 1;
    print $prompt;
    $handle->Flush;
    while (my $Data = $handle->InputChar(1)) {
        return if "n" eq $Data;
        return 1 if "y" eq $Data;
    }
    return;
}

