#!perl -w
#use strict;
my ($first_name, $last_name, $company_name, $address, $city, $county, $state, $zip, $phone1, $phone2, $email, $web);
my $file = "us-500.csv";
$~ = "FORMAT_TOP";
write;
$~ = "FORMAT_BODY";
open(FH, '<', $file) or die "Can't open $file: $!";
while (<FH>) {
    next if $. == 1;
    chomp;
    s/"//g;
    ($first_name, $last_name, $company_name, $address, $city, $county, $state, $zip, $phone1, $phone2, $email, $web) = split/,/;
    write;
}
$~ = "FORMAT_BOTTOM";
write;

format FORMAT_TOP=
+-----------+-------------+-----------+-----------------+------------+-------------+-------+-------+------+-------+------------+---------+
.
format FORMAT_BODY=
|@<<<<<<<<<<<|@<<<<<<<<<<<<<|@<<<<<<<<<<<|@<<<<<<<<<<<<<<<<<|@<<<<<<<<<<<<|@<<<<<<<<<<<<<|@<<<<<<<|@<<<<<<<|@<<<<<<|@<<<<<<<|@<<<<<<<<<<<<|@<<<<<<<<<
$first_name, $last_name, $company_name, $address, $city, $county, $state, $zip, $phone1, $phone2, $email, $web
.
format FORMAT_BOTTOM=
+-----------+-------------+-----------+-----------------+------------+-------------+-------+-------+------+-------+------------+---------+
.

