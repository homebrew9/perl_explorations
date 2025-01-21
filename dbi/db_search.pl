#!perl
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Name: db_search.pl
# Desc: From MJD's article "A Short Guide to DBI" at www.perl.com/pub/1999/10/DBI.html
# The table against which the searches are made is as follows:
# ---------------------------------------------------------------------------------------
#     connect amkjpf@t319
#     drop table people;
#     create table people (lastname varchar2(10), firstname varchar2(10), id int, postal_code varchar2(8), age int, sex varchar2(1));
#     insert into people (lastname, firstname, id, postal_code, age, sex)
#     select 'Gauss',    'Karl',    119, '19107',   30, 'M' from dual union all
#     select 'Smith',    'Mark',      3, 'T2V 3V4', 53, 'M' from dual union all
#     select 'Noether',  'Emmy',    118, '19107',   31, 'F' from dual union all
#     select 'Smith',    'Jeff',     28, 'K2G 5J9', 19, 'M' from dual union all
#     select 'Hamilton', 'William', 247, '10139',    2, 'M' from dual;
#     commit;
# ---------------------------------------------------------------------------------------
# Also see the following link for usage of Win32::Console to accept masked passwords:
# http://stackoverflow.com/questions/11217888/why-does-password-input-in-perl-using-win32console-require-pressing-enter-twic
# By: prat
# On: 1/3/2017
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
use strict;
use warnings;
use DBI;
use Win32::Console;
my $db;
my $user;
my $password;

# ---------------------------------------------------------------
# Subroutine section
# ---------------------------------------------------------------
sub run {
    my $StdIn = Win32::Console->new(STD_INPUT_HANDLE);
    $StdIn->Mode(ENABLE_PROCESSED_INPUT);
    $db = prompt_input($StdIn, "Enter db: ", ''); print "\n";
    $user = prompt_input($StdIn, "Enter user: ", ''); print "\n";
    $password = prompt_input($StdIn, "Enter password: ", '*');
    #if ( prompt_echo($StdIn, "\nShow password? [y/n] ") ) {print "\npassword = $password\n";}
    #print "\npassword = $password\n";
    return;
}

sub prompt_input {
    my ($handle, $prompt, $mask) = @_;
    my ($password);
    # From the perldoc
    # $| :  If set to nonzero, forces a flush right away and after every write or print on the currently
    # selected output channel. Default is 0 (regardless of whether the channel is really buffered by the
    # system or not; $| tells you only whether you've asked Perl explicitly to flush after each write).
    # STDOUT will typically be line buffered if output is to the terminal and block buffered otherwise. 
    local $| = 1;
    print $prompt;
    $handle->Flush;
    while (my $Data = $handle->InputChar(1)) {
        last if "\r" eq $Data;
        if ("\ch" eq $Data ) {
            if ( "" ne chop( $password )) {
                print "\ch \ch";
            }
            next;
        }
        $password .= $Data;
        print $mask eq '' ? $Data : $mask;
    }
    return $password;
}

#sub prompt_echo {
#    my ($handle, $prompt) = @_;
#    local $| = 1;
#    print $prompt;
#    $handle->Flush;
#    while (my $Data = $handle->InputChar(1)) {
#        return if "n" eq $Data;
#        return 1 if "y" eq $Data;
#    }
#    return;
#}

# ---------------------------------------------------------------
# Main section
# ---------------------------------------------------------------
# run();

my $StdIn = Win32::Console->new(STD_INPUT_HANDLE);
$StdIn->Mode(ENABLE_PROCESSED_INPUT);
$db = prompt_input($StdIn, "Enter db      : ", ''); print "\n";
$user = prompt_input($StdIn, "Enter user    : ", ''); print "\n";
$password = prompt_input($StdIn, "Enter password: ", '*'); print "\n";
#if ( prompt_echo($StdIn, "\nShow password? [y/n] ") ) {print "\npassword = $password\n";}
#print "\npassword = $password\n";

my $dbh = DBI->connect('DBI:Oracle:'.$db, $user, $password) or die "Couldn't connect to database: ".DBI->errstr;
my $sth = $dbh->prepare('SELECT * FROM people WHERE lastname = ?') or die "Couldn't prepare statement: ".$dbh->errstr;

# =================================================================================================================
# By: prat on 1/4/2017
# The handle to standard channel is broken if the DESTROY method of Win32::Console is (implicitly)
# invoked. See the following links:
#   http://stackoverflow.com/questions/8911574/how-to-ask-for-password-on-the-windows-console-in-a-perl-script
#   https://rt.cpan.org/Public/Bug/Display.html?id=19070
#   https://rt.cpan.org/Public/Bug/Display.html?id=33513
#   http://www.perlmonks.org/?node_id=886306
# Hence the line below cannot accept $lastname from <STDIN>.
# The following is the suggested workaround, but I could not make it to work on Windows.
#   close STDIN;
#   open STDIN, '+<CONIN$';
# =================================================================================================================

print "\n";
#while (my $lastname = <STDIN>) {    # Read input from the user
while (my $lastname = prompt_input($StdIn, "Enter name> ", '')) {    # Read input from the user
    my @data;
    chomp $lastname;
    $sth->execute($lastname) or die "Couldn't execute statement: ".$dbh->errstr;  # Execute the query
    # Read the matching records and print them out
    while (@data = $sth->fetchrow_array()) {
        my $firstname = $data[1];
        my $id = $data[2];
        print "\n\t$id:$firstname $lastname";
    }
    print "\n";
    if ($sth->rows == 0) {
        print "\nNo names matched '$lastname'.\n";
    }
    $sth->finish;
    print "\n";
}
$dbh->disconnect;

