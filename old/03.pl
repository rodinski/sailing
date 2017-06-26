use strict;
use warnings;
use Data::Dumper;
my @A;
for my $i ( qw ( dsq 34 35 35 dsq 35 37 dnf dnf 30 31 32 33 dnf dns dns  rc )) {
    push @A, $i;
}



#can a get this routine to rank things for me
#count numbers,  dsf and dsq 
#sum of these is the number of qualified boats (sum)
#note: toss out dns= did not start
#rank the numbers  ties get an average
#dns set to (sum)
#dqs set to (sum +2)
for my $i ( @A ) {
	#set the special variables $a and $b to use in <=> and cmp 
	#withing the sub by_numb_alpha
	$a = "dnf";
	$b = $i;
	my $c = by_numb_alpha ($a, $b);
	print   "$c ";
	print   "\n";
}

#sort_drop(@A,4);
#sort_drop(@A,'h');
print join " ", sort   by_numb_alpha  @A ; 
print "\n";

my @sorted = sort by_numb_alpha @A; #race results
my %rank_of_time;  #hash of results
my $last_match=1;

for (my $i=1; $i <= scalar @sorted - 1; $i++)   {
	my $back;
	    #a few lines for testing
		$back = $i-1;
		print "i:$i    s[$i]:$sorted[$i]    s[$back]:$sorted[$i-1] \n";
	#set thru sorted data looking for a change in result
	if ($sorted[$i] ne $sorted[$i-1]) {
		#so there is a change record the rank_of_time{$time}
		#use the average when skippers have the same outcome
		$rank_of_time{ $sorted[$i-1] }= ($last_match + $i) / 2.0;
	    $last_match = $i+1;
	}
    else {  #must be at a equal break
		#need to be able to finish this up with a check at 
		#the end
	}
}
#print Dumper(%rank_of_time);
for my $i (sort keys %rank_of_time) {
	print "key: $i   value: $rank_of_time{$i} \n";
}







sub by_numb_alpha {
    no warnings; 
    if ( $a + 0 > 0  && $b + 0 >  0  ) { return $a <=> $b}
    if ( $a + 0 > 0  && $b + 0 == 0  ) { return -1        }
    if ( $a + 0 == 0 && $b + 0 >  0  ) { return 1       }
    { return (lc $a) cmp (lc $b) } 
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
