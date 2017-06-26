#a simple set of examples in Perl

use strict;
use warnings;
use feature 'say';  # a good supstitue for 'print' that will add newlines
use Math::Round;    # better contol of rounded numbers

#useful modules for working with structured data
use YAML qw( LoadFile Load ); #LoadFile isn't exported by default
use Data::Dumper;

my ($bt,$defaults) = LoadFile('./boats.yaml');

# illistration of how to get output
print "Hello World!";
print "Hello World!";
print "\n\n";  # how output with newlines
print "Hello World!\n";
print "How are you?\n";
# '#" are for comments 


