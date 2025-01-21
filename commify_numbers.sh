##
# ==============================================================================
# Recipe 2.17 : Putting commas in numbers - from Perl Cookbook Edition 2
#
# Reverse the string so you can use backtracking to avoid substitution in the
# fractional part of the number. Then use a regular expression to find where
# you need commas, and substitute them in. Finally, reverse the string back.
# ==============================================================================
# Locale     |   Large Number
# -----------+-----------------------
# French     |   4 294 967 295,000  
# Spanish    |   4.294.967.295,000 
# US-English |   4,294,967,295.00  

#
perl -le '# Key   = <Locale>
          # Value = [<decimal_point>, <thousands_separator>]
          %fmt = ("FR" => [",", " "],
                  "US" => [".", ","],
                  "ES" => [",", "."]
                 );
          $x_template = "1234567890123456#8894";
          foreach $k (keys %fmt) {
              printf("\n%-20s : %s\n", "Locale", $k);
              ($dp, $sep) = @{$fmt{$k}};
              ($x = $x_template) =~ s/#/$dp/;
              printf("%-20s : %s\n", "Uncommified", $x);
              $dp = "\\." if $dp eq ".";
              $t = reverse $x;
              printf("%-20s : %s\n", "Uncommified reverse", $t);
              $t =~ s/(\d{3})(?=\d)(?!\d*$dp)/$1$sep/g;
              printf("%-20s : %s\n", "Commified reverse", $t);
              printf("%-20s : %s\n", "Commified", scalar reverse $t);
          }
         '


