#!perl
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# Name: transactions_1.pl
# Desc: From MJD's article "A Short Guide to DBI" at www.perl.com/pub/1999/10/DBI.html
# The table against which the searches are made is as follows:
# ---------------------------------------------------------------------------------------
#     connect amkjpf@t319
#     drop table employees;
#     create table employees (lastname varchar2(10), firstname varchar2(10), department_id int);
#     insert into employees (lastname, firstname, department_id)
#     select 'Gauss',    'Karl',     17 from dual union all
#     select 'Smith',    'Mark',     19 from dual union all
#     select 'Noether',  'Emmy',     17 from dual union all
#     select 'Smith',    'Jeff',    666 from dual union all
#     select 'Hamilton', 'William',  17 from dual;
#     
#     drop table departments;
#     create table departments (id int, name varchar2(12), num_members int);
#     insert into departments (id, name, num_members)
#     select  17, 'Mathematics',  3 from dual union all
#     select 666, 'Legal',        1 from dual union all
#     select  19, 'Grounds Crew', 1 from dual;
#     commit;
#     
#     select * from employees;
#     select * from departments;
#     
#     -- To test the transaction behavior, add the following constraint and invoke the new_employee
#     -- method until the constraint is violated.
#     alter table departments add constraint ck1_departments check (num_members < 4);
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

sub new_employee {
    # Arguments: database handle, first and last names of new employee
    # department ID number for new employee's work department
    my ($dbh, $first, $last, $department) = @_;
    my $insert_handle = $dbh->prepare_cached('INSERT INTO employees VALUES (?,?,?)');
    my $update_handle = $dbh->prepare_cached('UPDATE departments SET num_members = num_members + 1 WHERE id = ?');
    die "Couldn't prepare queries; aborting" unless defined $insert_handle && defined $update_handle;
    $insert_handle->execute($first, $last, $department) or return 0;
    $update_handle->execute($department) or return 0;
    return 1;  # Success
}

# ---------------------------------------------------------------
# Main section
# ---------------------------------------------------------------
# run();

my $StdIn = Win32::Console->new(STD_INPUT_HANDLE);
$StdIn->Mode(ENABLE_PROCESSED_INPUT);
$db = prompt_input($StdIn, "Enter db      : ", ''); print "\n";
$user = prompt_input($StdIn, "Enter user    : ", ''); print "\n";
$password = prompt_input($StdIn, "Enter password: ", '*'); print "\n";

my $dbh = DBI->connect('DBI:Oracle:'.$db, $user, $password) or die "Couldn't connect to database: ".DBI->errstr;

print "\n";
while (my $token = prompt_input($StdIn, "Enter fname,lname,deptid> ", '')) {    # Read input from the user
    chomp $token;
    my ($fname, $lname, $deptid) = split(/,/, $token);
    # I did not commit anywhere, but in Oracle I could see the "half-baked" state - INSERT was successful but
    # UPDATE failed and the data is corrupted. Looks like Perl DBI auto-commits by default - confirmed this as Perl
    # issues warnings like "commit ineffective with AutoCommit enabled".
    new_employee($dbh, $fname, $lname, $deptid);
    print "\n";
}
$dbh->disconnect;


