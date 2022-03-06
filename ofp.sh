#!/bin/bash
##Make sure you have gdown & xlsx2csv installed
##Install by <pip install gdown && pip install xlsx2csv>

[ "$(wc -m <<< "$1")" -ne 8  ] && {
	rm *.csv
	rm *.*xlsx
	exit 1
}

#Download sheet which contains ofp links.
gdown "$OFP_SHEET" # This var refers to a secret in .token.sh

#convert to csv file
xlsx2csv Software update summary form新版软件汇总表.xlsx > ofp.csv

#Grep links from csv file
touch temp.txt
grep "${1}.*${2}" ofp.csv | grep ".${3}." | egrep -o "(http|https)://[a-zA-Z0-9./?=_%:-]*" >temp.txt

#format output
echo ""
echo ""
sed -i "s/\n/\n\n/" temp.txt
text=$(cat temp.txt)
echo $text

#Delete files for next time
rm *.csv
rm *.*xlsx

################
