use strict;
use warnings;
use 5.012;
use 5.014;
use feature 'say';
use Math::Round;
#use Text::Table;
use Scalar::Util qw( looks_like_number );
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($table) = LoadFile('./dumper.yaml');
#say YAML::Dump $table;
say my $aa = $table->{skip}{Bill_P};
say my $bb = $table->{skip}{Barry_O};
#say join "  ",  keys $table->{skip}{Rod_H};
#say $aa->{low_n_sum};
#say $aa->{low_n_list};
#say $bb->{low_n_sum};
#say $bb->{low_n_list};

#say scalar @{ $aa->{low_n_list} };

for (my $i=0; $i <= ( scalar @{ $aa->{low_n_list} }-1 ); $i++) {
    say "index $i     $aa->{low_n_list}[$i]";
    say "index $i     $bb->{low_n_list}[$i]";
    say "";
}
foreach my $skip ( sort by_pts ( keys $table->{skip} ) ) {
    say "$skip  $table->{skip}{$skip}{low_n_sum}";
}



sub by_pts {
    my $aa = $table->{skip}{$a};
    my $bb = $table->{skip}{$b};
    my $a_ln = $aa->{low_n_sum};
    my $b_ln = $bb->{low_n_sum};
    no warnings; 

    #first chec low_n_sum
    if ( $aa->{low_n_sum}+ 0 > 0  &&  $bb->{low_n_sum}+ 0 >  0  ) {
        if ($a_ln == $b_ln) {
            # b/c ==  check the low_n_list in order 
            for (my $i=0; $i <= ( scalar @{ $aa->{low_n_list} }-1 ); $i++) {
                if ($aa->{low_n_list}[$i] != $bb->{low_n_list}[$i] ) {
                  #found a difference return
                  return $aa->{low_n_list}[$i] <=>  $bb->{low_n_list}[$i] 
                }
             }

        }
        
	   	return  $aa->{low_n_sum} <=>  $bb->{low_n_sum} 
    }
    if ( $aa->{low_n_sum}+ 0 > 0  &&  $bb->{low_n_sum}+ 0 == 0  ) {
	   	return -1  }
    if ( $aa->{low_n_sum}+ 0 == 0 &&  $bb->{low_n_sum}+ 0 >  0  ) { 
		return 1       }
    return (lc $a) cmp (lc $b);
	use warnings;
}
sub by_other {
    my $aa = $table->{skip}{$a};
    my $bb = $table->{skip}{$b};
    my $a_ln = $aa->{low_n_sum};
    my $b_ln = $bb->{low_n_sum};
    no warnings; 

    #first chec low_n_sum
    if ( $aa->{low_n_sum}+ 0 > 0  &&  $bb->{low_n_sum}+ 0 >  0  ) {
        return ($aa->{low_n_list}[$i] <=>  $bb->{low_n_list}[$i]
                                      || 
        if ($a_ln == $b_ln) {
            # b/c ==  check the low_n_list in order 
            for (my $i=0; $i <= ( scalar @{ $aa->{low_n_list} }-1 ); $i++) {
                if ($aa->{low_n_list}[$i] != $bb->{low_n_list}[$i] ) {
                  #found a difference return
                }
             }

        }
        
	   	return  $aa->{low_n_sum} <=>  $bb->{low_n_sum} 
    }
    if ( $aa->{low_n_sum}+ 0 > 0  &&  $bb->{low_n_sum}+ 0 == 0  ) {
	   	return -1  }
    if ( $aa->{low_n_sum}+ 0 == 0 &&  $bb->{low_n_sum}+ 0 >  0  ) { 
		return 1       }
    return (lc $a) cmp (lc $b);
	use warnings;
}
