use strict;
use warnings;
use 5.012;
use 5.014;
use feature 'say';
use Math::Round;
use Data::Dumper;

my @list;
for (my $i=1; $i lt 7; $i++) {
	push @list, round( rand(40)+1  );

}

push @list, "dnf";
push @list, "rip_23";
push @list, "rip_3";
push @list, "dsq";
push @list, "dnf";
push @list, "dnf";
say  join "\t", @list;
say  join  "\t",   rank(\@list);



sub rank { 
	my @rank;
	my $bigref = shift ;
	foreach my $lil ( @$bigref) {
		my %cnt = ( -1 => 0, 
		             0 => 0, 
					 1 => 0  );
		 foreach my $big ( @$bigref ) {
			#set the special variables $a and $b to use in <=> and cmp 
			#withing the sub by_numb_alpha
			$b = $lil;
			$a = $big;
			$cnt{ by_numb_alpha ($a, $b)}++; #count all the -1,0,1 values
		}
		#new %cnt has the number of >,==, and <  and rankings can be done
		
        push @rank , $cnt{-1}+1  + ( $cnt{0}-1 ) / 2.0;
		#i might need to be a number
		#special cases
        if ($lil =~ /dnf/i ) { pop @rank; push @rank, $cnt{-1}+$cnt{0}+$cnt{1 }};      #dsf =sum of racers
        if ($lil =~ /dsq/i ) { pop @rank; push @rank, $cnt{-1}+$cnt{0}+$cnt{1 } + 2};  #dsq=dsf+2
        if ($lil =~ /rip_/i  &&  $lil =~ /\d+/ ) { pop @rank; push @rank, $&  }        #input specified rank
  }
  return @rank;
}

sub by_numb_alpha {
    no warnings; 
    if ( $a + 0 > 0  && $b + 0 >  0  ) { return $a <=> $b}
    if ( $a + 0 > 0  && $b + 0 == 0  ) { return -1        }
    if ( $a + 0 == 0 && $b + 0 >  0  ) { return 1       }
    { return (lc $a) cmp (lc $b) } 
	use warnings;
}
