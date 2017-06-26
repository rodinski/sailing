# yam4.pl - Works also! Yippie!

use strict;
use warnings;
use feature 'say';

use YAML qw 'LoadFile';  #need to export this function, not standard function
use Data::Dumper;
my $bts = LoadFile('boats.yaml');

say Dumper($bts);
