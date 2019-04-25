#!/bin/sh
# run the perl program
# it has its input files hardcoded into it
# use the output to make a markdown file
perl -w race_scorer_v04.pl > rs.markdown
#
# call the MultiMarkdown program
# to create an html file that is good for 
# posting to the Google Sites site.
#
MultiMarkdown.pl rs.markdown > rs.html
#
#put file onto clipboard
xclip -selection clipboard rs.html
time=`ls -l rs.html |  awk   '{print $6, $7, $8}'`
echo ""
echo "rs.html from    $time"
echo "is on the clipboard"
echo ""
#gdrive upload 2016_s2.yaml
#gdrive upload 2016_s3.yaml
#gdrive upload 2017_s1.yaml
#gdrive upload 2017_s3.yaml
#gdrive upload 2018_s2.yaml
gdrive upload 2019_s1.yaml
less rs.markdown

