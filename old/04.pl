use strict;
use warnings;
use 5.012;
use 5.014;
use feature 'say';
use Math::Round;
use Data::Dumper;

my @list;
for (my $i=1; $i lt 7; $i++) {
	push @list, round( rand(20)  );

}
say join "_", @list;
say  join  " ",  rank(\@list);



sub rank { 

	my %rank;
	my $bigref = shift ;
	for (my $i = 0;   $i<=scalar @$bigref;  $i++){ say $bigref->[$i]; }
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
		
        $rank{$lil} = $cnt{-1}+1  + ( $cnt{0}-1 ) / 2.0;
		#i might need to be a number
        if ($lil =~ /dnf/i ) { $rank{$lil} = $cnt{-1}+$cnt{0}+$cnt{1 }}; #dsf =sum of racers
        if ($lil =~ /dsq/i ) { $rank{$lil} = $cnt{-1}+$cnt{0}+$cnt{1 } + 2}; #dsq=dsf+2

		#say join "_", @$bigref;
#		for my $key (sort keys %cnt){
#			say "$lil    $key=>$cnt{$key}";
#        }
		#say " rank $rank{$lil} " ; 
  }
  return %rank;
}

#for my $j ( @timelist ) {  
#	print "$j\t\t";
#	$c{-1}=0;	$c{ 0}=0;  $c{ 1}=0; #set counters to zero
#	for my $k ( @timelist ) {
#		#set the special variables $a and $b to use in <=> and cmp 
#		#withing the sub by_numb_alpha
#		$a = $k;
#		$b = $j;
#		$c{ by_numb_alpha ($a, $b)}++; #count all the -1,0,1 values
#	}
# $rank{$j} = $c{-1}+1  + ( $c{0}-1 ) / 2.0;
# if ($j =~ /dnf/i ) { $rank{$i} = $c{-1}+$c{0}+$c{1 }}; #dsf =sum of racers
# if ($j =~ /dsq/i ) { $rank{$i} = $c{-1}+$c{0}+$c{1 } + 2}; #dsq=dsf+2
# for my $key (sort  keys %c ) {
#	 print "$key->$c{$key}   " ;
# }
# say "== $rank{$j}";
#} #$j end of @timelist
sub by_numb_alpha {
    no warnings; 
    if ( $a + 0 > 0  && $b + 0 >  0  ) { return $a <=> $b}
    if ( $a + 0 > 0  && $b + 0 == 0  ) { return -1        }
    if ( $a + 0 == 0 && $b + 0 >  0  ) { return 1       }
    { return (lc $a) cmp (lc $b) } 
	use warnings;
}
