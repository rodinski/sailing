use strict;
use warnings;
use 5.012;
use 5.014;
use feature 'say';
use Math::Round;
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($bt,$defaults) = LoadFile('boats.yaml');
#my $r =  LoadFile('races_02.yml');
my $r =  LoadFile('races_2015_s3.yaml');
my $table; #ref to a data structure for later results
my $races_held = 0;  #counter



for my $i (sort by_numb_alpha   keys  %{$r->{race}}  ) {

	my $wind = $r->{race}{$i}{wind};

	my %at; #hash of actual time in the yaml file.
	# get corrected times and deal with DNS and DNF maybe no skipers for a race 
	if  (!defined $r->{race}{$i}{skip} ) {$r->{race}{$i}{number_of_starters} = 0};
	if  ( defined $r->{race}{$i}{skip} )  { 	# note using a hash reference here

		my %ct = (); #empty the hash
		for my $s ( sort keys %{ $r->{race}{$i}{skip} } ) {
			 #say "skipper is $s";
			
			my $bn;
			if (exists $r->{race}{$i}{skip}{$s}{boat}) {
				$bn = $r->{race}{$i}{skip}{$s}{boat};     #bn=boatname overide
			}  
			else {
                $bn = $defaults->{name}{$s}{boat};
		        $r->{race}{$i}{skip}{$s}{boat} = $bn;
			}

			my $hc   = $bt->{boat}{$bn}{hc_of_wind}{$wind}; #hc=handycap
            $r->{race}{$i}{skip}{$s}{hc} =  $hc;
			my $time = $r->{race}{$i}{skip}{$s}{time};  #time, could be alpha ei DNF
			my $a_time;
		    $at{ $s } = $a_time;
			if ($time =~ /:/) {	#these have a time in mm:ss					
				my @t = split  (/:/, $time);
				$a_time = $t[0] * 60 + $t[1];
                $r->{race}{$i}{skip}{$s}{a_time} =  $a_time;
				my $c_time = round($a_time / $hc * 100) ; 
				$r->{race}{$i}{skip}{$s}{c_time} =  $c_time;
				$ct{ $s } = $c_time
			} # end of time correction if
			#elsif ( $time =~ /dns/i ) {} #drop the dns
			else {  #likely FIP  DNF or DSQ no corrections but they  still
				#figure into the scoreing	
				$r->{race}{$i}{skip}{$s}{c_time} = $time;
                $r->{race}{$i}{skip}{$s}{a_time} =  $time;  #still need something in this spot 
				$ct{ $s } = $time;
			} # Finish-in-Place, DNF or DSQ 
			
		} # end of a races skippers


        #begin to pack away the c_times so they can be ranked later
        my @rank_l;    #pack an array of  ranking
		my @skippers;  #pack an array of skippers
		# now go back to the skippers again for a given race
		for my $s (sort keys  %{ $r->{race}{$i}{skip} }  ) {
			#don't include DNS's
			if ($r->{race}{$i}{skip}{$s}{time} !~ /dns/i) {
				push @rank_l, $r->{race}{$i}{skip}{$s}{c_time}; 
				push @skippers, $s; 
			}
		} 

       
		say "\n"x2 . "=-"x39;
		say "Race No.: $i    Wind: $wind (BFT)    RC=  ".(join  ", ", @{ $r->{race}{$i}{RC} });
		say "Date: $r->{race}{$i}{date}";
	   $~ = "race_head";
	   write;
       $r->{race}{$i}{number_of_starters} = scalar @skippers ;
	   if (scalar @skippers > 1) { $races_held++ }  
	   @rank_l = rank(\@rank_l);  # b/c there are skippers, rank them

	   $~ = "race_body";
       for my $s (@skippers) {
           my $rnk  = shift @rank_l;
		   my $sref = $r->{race}{$i}{skip}{$s};
           $r->{race}{$i}{skip}{$s}{rank}  = $rnk;
		   $table->{skip}{$s}{race}{$i} = $rnk;  #some datastructure of results
           no warnings; 
		   #printf  "%14s on %-6s  %6s    %6s / %5.3f = %4s  %6s   %6s\n",
			   my @a =  ($s, 
			   $r->{race}{$i}{skip}{$s}{boat},
			   $r->{race}{$i}{skip}{$s}{time},
			   $r->{race}{$i}{skip}{$s}{a_time},
			   $r->{race}{$i}{skip}{$s}{hc}/100,
			   $r->{race}{$i}{skip}{$s}{c_time}, 
			   mm_ss ($r->{race}{$i}{skip}{$s}{c_time}), 
			   " "x$rnk.$rnk );
		   write; 
           use warnings; 
		   

format race_head = 
                     a_timb                       c_time
       Name   Boat   mm:ss   sec  /   hc  =c_sec   mm:ss  Rank 
-----------   ----   -----   -------------------   -----  ----------
.
format race_body = 
@>>>>>>>>> on @<<<<<  @>>>>  @<<< / @<<<<<=@<<<<<  @>>>>  @<<<<<<<<<<<<<<<<<<<<<<<<
	(shift @a,shift @a,shift @a,shift @a,shift @a,shift @a,shift @a,shift @a)
.
	   } #end of ranking the finisher(skippers) of a given race
	#say Dumper($r->{race}{$i}	   );
	}  #end of a defined skipper

   #Now start to fill in a table data stucture of results
   #fill in the RC names, even if there are no skipper could still have RC
   #note we are stepping thru a list not a hash
   foreach my $s ( 	@{$r->{race}{$i}{RC} } )  {
	   $table->{skip}{$s}{race}{$i} = "RC"; 
   } 

} #end of all races


say "";
say "--+--"x14;
my $n_races = scalar keys %{ $r->{race} };  #all races 
my $races_needed_to_q = int ($races_held / 2); 

for my $name (sort keys %{ $table->{skip} } ) {
    my $finished_races=0;
    my $rced_races=0;
	for my $race (sort by_numb_alpha keys %{ $r->{race} }) {  
	    if (defined $table->{skip}{$name}{race}{$race}	) {
			#printf "%-6s",$table->{skip}{$name}{race}{$race};
			no warnings;
			if ($table->{skip}{$name}{race}{$race}+0 > 0)       {$finished_races++}
			use warnings;
			if (uc $table->{skip}{$name}{race}{$race} eq 'RC')  {$rced_races++}
		}
		else {
			#print " -    "
			};
	}
    $table->{skip}{$name}{finished_races} = $finished_races;
    $table->{skip}{$name}{rced_races} = $rced_races;
	my $race_ref = $table->{skip}{$name}; 
	#add a new key=>value pair for the rc_points 
	$race_ref->{rc_points} = rc_calc2 (sort by_numb_alpha values %{ $race_ref->{race} });
	my $pts = sub_low_n ($table->{skip}{$name}{race}, $races_needed_to_q);
    $table->{skip}{$name}{low_n} = $pts;

}  #end of skippers loop

# say Dumper($r);
# say Dumper($table);

say "races_held  = $races_held";
say "races_needed_to_q = $races_needed_to_q"; 

select(STDOUT);
my @rr;

$~ = "Standings_Head";
write;
$~ = "Standings_Body";
for my  $name (sort   by_pts keys   %{ $table->{skip} } ) {
    @rr = ();    	
    foreach my $race (sort by_numb_alpha keys %{ $r->{race} } ) {
		#create a list of results
		my $rr = defined $table->{skip}{$name}{race}{$race} ? 
		                 $table->{skip}{$name}{race}{$race} : 
						 "-";
	    push @rr, $rr;
	}
	my $pts = sub_low_n ($table->{skip}{$name}{race}, $races_needed_to_q);
  write; 


format Standings_Head = 

Name / Boat          Race 
              @*
                 join "   ", sort by_numb_alpha keys %{ $r->{race} }, "RCpt    PTS" 
             @*
               sprintf " -- "x scalar keys %{ $r->{race} } 
.
format Standings_Body = 
@>>>>>>>>  @*  @>>>>>  @>>>>
$name,  (sprintf "%4s"x scalar @rr, @rr),  $table->{skip}{$name}{rc_points}, $pts
.


}


#------ subroutines --------------------------------
sub sub_low_n {
   my $score_ref =  shift ;
   my $n     =  shift ;
   my @both =	sort by_numb_alpha values %$score_ref;
   if (rc_calc2(@both) eq 'na') {return 'na'}
   my $rc_pts = rc_calc2(@both); 
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
   #print  join "+ ", @scr[0 .. $n-1];
   my $low_n =  sum_n([@scr],$n);
   #say "\$low_n  $low_n";
   return $low_n; 
   }

#------ subroutines --------------------------------
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



#------ subroutines --------------------------------
sub rc_calc2 {
	my @array = sort by_numb_alpha  (grep {/\d/} @_);
	if  ( scalar @array == 0  ) {return "na"} 
	if  ( scalar @array == 1  ) {return $array[0]} 
	pop @array ;
	my $sum = 0;
	for (my $i=0; $i <= scalar @array-1 ; $i++) {
		$sum += $array[$i];
	}
	return nearest(0.1,($sum / scalar @array)) ;
}
#--------------------------------------

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
		##dsf =sum of racers
        if ($lil =~ /dnf/i ) { pop @rank; push @rank, $cnt{-1}+$cnt{0}+$cnt{1 }};      
        #dsq=dsf+2
        if ($lil =~ /dsq/i ) { pop @rank; push @rank, $cnt{-1}+$cnt{0}+$cnt{1 } + 2};
		#input specified rank
        if ($lil =~ /rip_/i  &&  $lil =~ /\d+/ ) { pop @rank; push @rank, $&  } 
  }
  return @rank;
}
#--------------------------------------
sub by_numb_alpha {
    no warnings; 
    if ( $a + 0 > 0  && $b + 0 >  0  ) { return $a <=> $b}
    if ( $a + 0 > 0  && $b + 0 == 0  ) { return -1        }
    if ( $a + 0 == 0 && $b + 0 >  0  ) { return 1       }
    return (lc $a) cmp (lc $b);
	use warnings;
}
#--------------------------------------
sub by_pts {
    no warnings; 
    if ( $table->{skip}{$a}{low_n}+ 0 > 0  &&  $table->{skip}{$b}{low_n}+ 0 >  0  ) {
	   	return  $table->{skip}{$a}{low_n} <=> $table->{skip}{$b}{low_n} }
    if (  $table->{skip}{$a}{low_n}+ 0 > 0  &&  $table->{skip}{$b}{low_n}+ 0 == 0  ) {
	   	return -1  }
    if (  $table->{skip}{$a}{low_n}+ 0 == 0 &&  $table->{skip}{$b}{low_n}+ 0 >  0  ) { 
		return 1       }
    return (lc $a) cmp (lc $b);
	use warnings;
}
#--------------------------------------
sub mm_ss { 
	my $sec = shift;
	no warnings;
	if ($sec > 0 ) {
		use warnings;
		my $mm;
		my $ss;
		$mm = sprintf ("%02d", $sec/60.0);
		$ss = sprintf ("%02d", $sec % 60);
		return "$mm:$ss";
	}
	else {return $sec};
}


#sub rc_calc {
#	my @array = sort by_numb_alpha @_;
#	#check if RC exists and if either first two values are RC
#	#if  (!grep {/RC/i} @array) {return "na"} #no RC duty
#	#if  ( $array[0] =~ /RC/i || $array[1] =~ /RC/i ) {return "na"} #only RC duty
#	if  ( $array[0] =~ /RC/i ) {return "na"} #only RC duty
#	if  ( $array[1] =~ /RC/i ) {return $array[0]}  #only one scort duty
#
#	my $sum = 0;
#    if (scalar  @array ==1) {return $array[0]}
#	for (my $i=0; $i <= scalar  @array ; $i++) {
#		no warnings;
#		if ($array[$i] =~ /RC/i || $i == scalar @array) { return nearest(0.1,($sum-$array[$i-1]) / ($i-1)) }
#		use warnings;
#		$sum += $array[$i];
#	}
#}
#--------------------------------------
#set ts=4				
