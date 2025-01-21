#!perl
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Name: qry_noncached.pl
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
# Check the main program: db_search.pl for more issues related to Win32::Console and why I wrote it the way I did.
# By: prat
# On: 1/5/2017
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

sub age_by_id {
    # Arguments: database handle, person ID number
    my ($dbh, $id) = @_;
    my $sth = $dbh->prepare('SELECT age from people WHERE id = ?') or die "Couldn't prepare statement: ".$dbh->errstr;
    $sth->execute($id) or die "Couldn't execute statement: ".$sth->errstr;
    my ($age) = $sth->fetchrow_array();
    return $age;
}

# ---------------------------------------------------------------
# Main section
# ---------------------------------------------------------------
my $StdIn = Win32::Console->new(STD_INPUT_HANDLE);
$StdIn->Mode(ENABLE_PROCESSED_INPUT);
$db = prompt_input($StdIn, "Enter db      : ", ''); print "\n";
$user = prompt_input($StdIn, "Enter user    : ", ''); print "\n";
$password = prompt_input($StdIn, "Enter password: ", '*'); print "\n";

my $dbh = DBI->connect('DBI:Oracle:'.$db, $user, $password) or die "Couldn't connect to database: ".DBI->errstr;

print "\n";
while (my $pers_id = prompt_input($StdIn, "Enter id> ", '')) {    # Read input from the user
    my $pers_age = age_by_id($dbh, $pers_id);
    print "\n\tAge = $pers_age\n" if defined $pers_age;
    print "\n";
}
$dbh->disconnect;

