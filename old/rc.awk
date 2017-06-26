/^$/     {print "  #:"
          print "    skip:"
      }

/^[0-9]/  {  print "      " $2 ":"
          print "        boat: " $3
          print "        time: " $4
}

