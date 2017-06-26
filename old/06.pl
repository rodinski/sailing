use strict;
use warnings;
use feature "say";
use Math::Round;
use Data::Dumper;
my @A;
for my $i ( qw (  3 3 2 2 6 7  rc rc   )) {
    push @A, $i;
}


#sort_drop(@A,4);
#sort_drop(@A,'h');
print join " ",  @A ; 
print "\n";
print join " ", sort  by_numb_alpha  @A ; 
print "\n\n";


my $sorted_ref = [sort by_numb_alpha @A]; #race results
my $min=6;
my $answer = low_n ($sorted_ref , $min);
say "low of  $min  values is  $answer";





sub low_n {
   my $score_ref =  shift ;
   my $n     =  shift ;
   my @both =	sort by_numb_alpha @$score_ref;
   my $rc_pts = rc_calc(@both); 
   my @scr =  grep(/^\d/i, @both);
   my $rc_cnt = scalar grep(/rc/i, @both);
   if ($rc_cnt > 2) {$rc_cnt = 2};

   if (scalar @scr + $rc_cnt < $n) {return "DNQ"; exit};

   # start with at least $n values
   while (scalar @scr < $n && $rc_cnt >  0 ) {
	   push @scr,$rc_pts;
	   @scr = sort by_numb_alpha @scr;
	   $rc_cnt--;
   }  

   #now i should have $n scores and and can replace 
   # on the high end with a pop and a push and a sort
   while ($rc_cnt) {
	   if($rc_pts < $scr[$n-1]) {
		   pop @scr;
		   push @scr,$rc_pts;
		   @scr = sort by_numb_alpha @scr;
	   }
	   $rc_cnt--;
   }
   #say join "+ ", @scr[0 .. $n-1];
   my $low_n =  sum_n([@scr],$n);
   #say "\$low_n  $low_n";
   return $low_n; 
   }


sub sum_n {  # takes an ref_to_array and an integer
	 my $a_ref = shift;
	 my @scores = @$a_ref;
	 my $n = shift;
	 #say "array_ref  $a_ref   \$n = $n" ;
	 my $sum = 0;
	 for (my $i=0; $i<=($n-1); $i++){
		 #say $scores[$i];
		 $sum += $scores[$i];
	 }
	 #say "sum = $sum";
	 return $sum;
 }



sub by_numb_alpha {
    no warnings; 
    if ( $a + 0 > 0  && $b + 0 >  0  ) { return $a <=> $b}
    if ( $a + 0 > 0  && $b + 0 == 0  ) { return -1        }
    if ( $a + 0 == 0 && $b + 0 >  0  ) { return 1       }
    { return $a cmp $b} 
	use warnings;
}

sub sort_drop  {
    my $drops =  pop @_;
    my @list = sort {$a <=> $b} @_; #numeric sort 
    my $size = scalar @list;
    print "count of list $size \n";
    print join " ",  @list;
    print "\n"; 
    if ( lc $drops =~ /h/ ) { $drops = sprintf ("%d", $size / 2)}
    print "drop $drops\n";
    for (my $i = $drops; $i>0; $i--) {pop @list }
    print join " ", @list;
    print "\n\n";

}

sub rc_calc {
	my @array = sort by_numb_alpha @_;
	#check if RC exists and if either first two values are RC
	if  (!grep {/RC/i} @array) {return "99"} #no RC duty
	if  ( $array[0] =~ /RC/i || $array[1] =~ /RC/i ) {return "98"} #only RC duty

	my $sum = 0;
	for (my $i=0; $i <= scalar  @array ; $i++) {
		if ($array[$i] =~ /RC/i) { return nearest(0.1,($sum-$array[$i-1]) / ($i-1)) }
		$sum += $array[$i];
	}
}
