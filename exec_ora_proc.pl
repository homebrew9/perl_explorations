#!perl
#===============================================================================
# Name : exec_ora_proc.pl
# Desc : A short Perl program to connect to an Oracle schema and run a stored
#        procedure in there. This can be used as a test case to check if the
#        database rolls back uncommitted changes upon encountering an exception
#        in the procedure.
#        The database schema was prepared as follows:
#        -----------------------------------------------------------------------
#        --
#        drop procedure pr_load_data;
#        drop table t1;
#        drop table t2;
#        drop table t3;
#        --
#        create table t1 (x int, y varchar2(1));
#        create table t2 (x int, y varchar2(1));
#        create table t3 (x int, y varchar2(1));
#        alter table t3 add constraint ck1_t3 check (x < 2);
#        --
#        create or replace procedure pr_load_data
#        as
#        begin
#            insert into t1(x, y) values (1, 'a');
#            insert into t1(x, y) values (2, 'b');
#            insert into t1(x, y) values (3, 'c');
#            --
#            insert into t2(x, y) values (1, 'a');
#            insert into t2(x, y) values (2, 'b');
#            insert into t2(x, y) values (3, 'c');
#            --
#            insert into t3(x, y) values (1, 'a');
#            -- The next INSERT will throw an exception and the one after it will never be executed.
#            insert into t3(x, y) values (2, 'b');
#            insert into t3(x, y) values (3, 'c');
#        end;
#        /
#        show errors
#        -----------------------------------------------------------------------
# Usage: perl exec_ora_proc.pl <schema> <password> <database>
#===============================================================================
use DBI;
use strict;
use vars qw($dbh $sth $sql);

if ($#ARGV != 2){
    print "Usage: perl exec_ora_proc.pl <schema> <password> <database>\n";
    exit;
}
my ($user, $pswd, $db) = @ARGV;

# Open a connection to the database. Set autocommit to "off" (0 = off, 1 = on).
$dbh = DBI->connect('dbi:Oracle:'.$db, $user, $pswd, {AutoCommit => 0});
$sql = "BEGIN pr_load_data; END;";

eval {
    $sth = $dbh->prepare($sql);
    $sth->execute();
}
or do {
    # I want to capture the exception, print a message and then commit.
    my $error = $@ || 'Unknown failure';
    printf("\nAn error was thrown by the database procedure. Error = [%s]\n\n", $error);
    $dbh->commit();
};

# Now I fetch data from tables T1, T2, T3. Data was loaded into T1, T2, T3
# before the exception was thrown but the database rolled back the work done.
# Hence no records are returned here. It doesn't matter if I commit or rollback
# in the exception capture block above; that data is lost forever.

# Fetch the data from tables T1, T2 and T3.
print "Fetching from table T1\n";
$sth = $dbh->prepare('select x, y from t1');
$sth->execute();
while (my ($x, $y) = $sth->fetchrow()){
    printf("%5d %-5s\n", $x, $y);
}

print "Fetching from table T2\n";
$sth = $dbh->prepare('select x, y from t2');
$sth->execute();
while (my ($x, $y) = $sth->fetchrow()){
    printf("%5d %-5s\n", $x, $y);
}

print "Fetching from table T3\n";
$sth = $dbh->prepare('select x, y from t3');
$sth->execute();
while (my ($x, $y) = $sth->fetchrow()){
    printf("%5d %-5s\n", $x, $y);
}

$sth->finish();
$dbh->disconnect();

