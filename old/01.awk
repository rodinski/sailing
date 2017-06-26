BEGIN {FS="\t"
    print "---"
    print "boat:"
}
{
print "  "$2":"
print "    full_name: "$1
print "    hc_of_wind:"
print "      D-PN:   "$3         
print "      0-1:    "$4 
print "      2-3:    "$5
print "      4:      "$6
print "      5-9:    "$7 
}
