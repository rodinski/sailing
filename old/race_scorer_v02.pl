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

my $version_string = "race_scorer_v02.pl version 0.2 coded: 2015_09_14";
say $version_string;

my ($bt,$defaults) = LoadFile('./boats.yaml');
my $r =  LoadFile('./races_2015_s1.yaml');
say $version_string;
my $table; #ref to a data structure for later results
my $races_held = 0;  #counter



for my $i (sort by_numb_alpha   keys  %{$r->{race}}  ) {

	my $wind = $r->{race}{$i}{wind};
	
	foreach my $s ( 	@{$r->{race}{$i}{RC} } )  { #save RC list
	   $table->{skip}{$s}{race}{$i} = "RC"; 
	} 

	if  (!defined $r->{race}{$i}{skip} ) { #no skippers for a race
		$r->{race}{$i}{number_of_starters} = 0;
	    next ;   #exit this race
	}  
	# get corrected times and deal with DNS and DNF  
	my %ct = (); #empty the hash  of  "skipper"=>corrected_time
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

		# error if hc can not be found
		if (!exists($bt->{boat}{$bn}{hc_of_wind}{$wind})) {say "**  No hc for $s  **"}

		my $hc   = $bt->{boat}{$bn}{hc_of_wind}{$wind}; #hc=handycap
		$r->{race}{$i}{skip}{$s}{hc} =  $hc;
		my $time = $r->{race}{$i}{skip}{$s}{time};  #time, could be alpha ei DNF
		my $a_time;
		if ($time =~ /:/) {	#these have a time in mm:ss					
			my @t = split  (/:/, $time);
			$a_time = $t[0] * 60 + $t[1];
			$r->{race}{$i}{skip}{$s}{a_time} =  $a_time;
			my $c_time = round($a_time / $hc * 100) ; 
			$r->{race}{$i}{skip}{$s}{c_time} =  $c_time;
			$ct{ $s } = $c_time
		} # end of time correction if
		elsif ( $time =~ /dns/i ) { next } #drop the dns
		else {  #likely FIP  DNF or DSQ no corrections but they  still
			#figure into the scoreing	
			$r->{race}{$i}{skip}{$s}{c_time} = $time;
			$r->{race}{$i}{skip}{$s}{a_time} =  $time;  #still need something in this spot 
			$ct{ $s } = $time;
		} # Finish-in-Place, DNF or DSQ 
		
	} # end of a races skippers
	#say "ct hash = :";
	#say join " ", map { "$_=>$ct{$_}"  }  keys %ct;
	#say scalar  keys %ct;


   
	say "\n"x2 . "=-"x36;
	print "Race Number: $i    Wind: $wind (BFT)    ";
	say "RC:  ".(join  ", ", @{ $r->{race}{$i}{RC} });
	say "Date: $r->{race}{$i}{date}";
	say "Notes: $r->{race}{$i}{notes}";
   $~ = "race_head";
   write;
   $r->{race}{$i}{number_of_starters} = scalar keys %ct ;
   if (scalar scalar keys %ct > 1) { $races_held++ }  


   $~ = "race_body";

   for my $s ( sort keys %ct) {
	   my $rnk  = race_pt ($ct{$s}, values %ct);
	   my $sref = $r->{race}{$i}{skip}{$s};
	   $r->{race}{$i}{skip}{$s}{rank}  = $rnk;  #store these in r and table
	   $table->{skip}{$s}{race}{$i} = $rnk;  #some datastructure of results
	   no warnings; 
	   my @a =  ($s, 
		   $sref->{boat},
		   $sref->{time},
		   $sref->{a_time},
		   $sref->{hc}/100,
		   $sref->{c_time}, 
		   mm_ss ( $sref->{c_time} ), 
		   " "x$rnk.$rnk );
	   write; 
	   use warnings; 
# -----------------------------------------------------------------------------
format race_head = 
                     a_timb                       c_time
       Name   Boat   mm:ss   sec  /   hc  =c_sec   mm:ss  Rank 
-----------   ----   -----   -------------------   -----  ----------
.
# -----------------------------------------------------------------------------
format race_body = 
@>>>>>>>>> on @<<<<< @>>>>   @<<< / @<<<<<=@<<<<<  @>>>>  @<<<<<<<<<<<<<<<<<<<<<<<<
	(shift @a,shift @a,shift @a,shift @a,shift @a,shift @a,shift @a,shift @a)
. 
# -----------------------------------------------------------------------------
   } #end of ranking the skippers of a given race
#say Dumper($r->{race}{$i}	   );
}  #end of all race
 







say "";
say "--+--"x14;
my $n_races = scalar keys %{ $r->{race} };  #all races 
my $races_needed_to_q = int ($races_held / 2); 

for my $s (sort keys %{ $table->{skip} } ) {
    my $finished_races=0;
    my $rced_races=0;
	for my $race (sort by_numb_alpha keys %{ $r->{race} }) {  
	    if (defined $table->{skip}{$s}{race}{$race}	) {
			#printf "%-6s",$table->{skip}{$s}{race}{$race};
			no warnings;
			if ($table->{skip}{$s}{race}{$race}+0 > 0)       {$finished_races++}
			use warnings;
			if (uc $table->{skip}{$s}{race}{$race} eq 'RC')  {$rced_races++}
		}
		else {
			#print " -    "
			};
	}
    $table->{skip}{$s}{finished_races} = $finished_races;
    $table->{skip}{$s}{rced_races} = $rced_races;
	my $race_ref = $table->{skip}{$s}; 
	#add a new key=>value pair for the rc_points 
	$race_ref->{rc_points} = rc_calc (sort by_numb_alpha values %{ $race_ref->{race} });
    
    my @lowest_n_pts = low_n_list ($table->{skip}{$s}{race}, $races_needed_to_q);
    my $pts;
    if ( looks_like_number ($lowest_n_pts[-1]) ) { 	
		$pts = eval join "+", @lowest_n_pts #must me all numbers so sum them
	}
	else { $pts = $lowest_n_pts[-1] }   #must be  na or DNQ
    $table->{skip}{$s}{low_n_list} = [@lowest_n_pts];
    $table->{skip}{$s}{low_n_sum} = $pts;

}  #end of skippers loop

# say Dumper($r);
# say Dumper($table);

say "";
say "             Races Held: $races_held";
say "Races Needed to Qualify: $races_needed_to_q"; 

select(STDOUT);
my @r_res;  #array of race results
$~ = "Standings_Head";   #heading form for the standings
write;
$~ = "Standings_Body";

for my  $s (sort   by_pts keys   %{ $table->{skip} } ) {
    @r_res = ();    	
    foreach my $race (sort by_numb_alpha keys %{ $r->{race} } ) {
		#create a list of results  "-" when not defined
	    push @r_res, defined $table->{skip}{$s}{race}{$race} ? 
		                 $table->{skip}{$s}{race}{$race} : 
						 "-";
	}
  my $pts_col = ( sprintf "%8s",$table->{skip}{$s}{low_n_sum} ) . 
               " = ". 
			   join " ",@{$table->{skip}{$s}{low_n_list}} ;
  write; 
# ---------------------------------------------------------------------------
format Standings_Head = 

Name / Boat          Race 
              @*
               join "   ", sort by_numb_alpha keys %{ $r->{race} }, "RCpt    PTS" 
             @*
               sprintf " -- "x scalar keys %{ $r->{race} } 
.
# -----------------------------------------------------------------------------
format Standings_Body = 
@>>>>>>>>  @*  @>>>>>  @*
$s,  (sprintf "  %3s"x(scalar @r_res), @r_res),  $table->{skip}{$s}{rc_points}, $pts_col
.
# -----------------------------------------------------------------------------

}
say "\n";
say $version_string;
#my $sep = " | ";
#my $sep_e = "  =  ";
#my $sep_l = "|";
#my $sep_r = "|";
#my $tb=Text::Table->new(\$sep_l,"Sikpper",
#                         \$sep,"Points",
#					     \$sep_e,"Low Scores",
#					     \$sep_r);
#$tb->rule("-","+");
#$tb->add('-');
#my $cnt = 0;
#for my  $s (sort   by_pts keys   %{ $table->{skip} } ) {
#	$cnt++;
#	$tb->add($s,$table->{skip}{$s}{low_n_sum},join " + ",@{$table->{skip}{$s}{low_n_list}},);
#	if($cnt % 3 == 0) { $tb->add('-'x${[$tb->colrange(0)]}[1],
#			                     '-'x${[$tb->colrange(1)]}[1],
#						         '-'x${[$tb->colrange(2)]}[1])  }
#}
#print "\n"x3;

#print $tb->rule("-","+");
#print $tb;
#say $tb->title();
#say $tb->rule();


#------ subroutines --------------------------------
sub low_n_list {
   my $score_ref =  shift ;
   my $n     =  shift ;
   my @both =	sort by_numb_alpha values %$score_ref;
   if (rc_calc(@both) eq 'na') {return 'na'}
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
   return  @scr[0 .. $n-1]; 
   }
#------ subroutines --------------------------------



#------ subroutines --------------------------------
sub sum_n {  # takes a ref_to_array and an integer
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
sub rc_calc {
	my @array = sort by_numb_alpha  (grep {/\d/} @_);
	if  ( scalar @array == 0  ) {return "na"} 
	if  ( scalar @array == 1  ) {return $array[0]} 
	pop @array ; #drop the highest value
	my $sum = 0;
	
	for (my $i=0; $i <= scalar @array-1 ; $i++) {
		$sum += $array[$i];
	}
	return nearest(0.1,($sum / scalar @array)) ;
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
    if ( $table->{skip}{$a}{low_n_sum}+ 0 > 0  &&  $table->{skip}{$b}{low_n_sum}+ 0 >  0  ) {
	   	return  $table->{skip}{$a}{low_n_sum} <=> $table->{skip}{$b}{low_n_sum} }
    if (  $table->{skip}{$a}{low_n_sum}+ 0 > 0  &&  $table->{skip}{$b}{low_n_sum}+ 0 == 0  ) {
	   	return -1  }
    if (  $table->{skip}{$a}{low_n_sum}+ 0 == 0 &&  $table->{skip}{$b}{low_n_sum}+ 0 >  0  ) { 
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
#--------------------------------------
sub race_pt { 
	# takes one number then a list of numbers and calculates 
	# sailboat racing points.
	#
	my $t = shift ; #get the time of interest
	my @ctimes = @_ ; # copy the remaining list
	my %cnt = ( -1 => 0, 
				 0 => 0, 
				 1 => 0  );

	foreach my $i ( @ctimes ) {
		#set the special variables $a and $b to use in <=> and cmp 
		#withing the sub by_numb_alpha
		$a = $t;	
		$b = $i; 
		$cnt{ by_numb_alpha ($a, $b)}++; #count all the -1,0,1 values
		#say "cnt returns for  $a  and $b   =".  by_numb_alpha ($a , $b);
	}
	if ($cnt{0} == 0) {say "$t is not in the list of times, this is likely an error"}
	#new %cnt has the number of >,==, and <  and rankings can be done
	#
	my $race_pt = $cnt{1}+1  + ( $cnt{0}-1 ) / 2.0;
	#special cases
	##dsf =sum of racers
	#no warnings;
	if ($t =~ /dnf/i ) {$race_pt =  $cnt{-1}+$cnt{0}+$cnt{1 }};      
	##dsq=dsf+2
	if ($t =~ /dsq/i ) {$race_pt = $cnt{-1}+$cnt{0}+$cnt{1 } + 2};
	##input specified rank
	if ($t =~ /fip_/i  &&  $t =~ /\d+/ ) { $race_pt =  $&  } 
	#use warnings;
	return $race_pt;
}

#say Dumper($r);
#say Dumper($table);


#set ts=4				
