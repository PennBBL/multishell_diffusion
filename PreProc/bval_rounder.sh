#!/bin/bash
# ---------------------------------------------------------------
# BVAL_ROUNDER.sh - round b-val file to nearest multiple of provided integer
#	meant to clean up b-vals from Siemens dicom headers 
#   
# M. Elliott - 2017

if [ $# -ne 3  ]; then 
	echo "usage: `basename $0` <bvalfile> <resultfile> integer-multiple"
    exit 1
fi

fac=$3								# nearest integer multiple of this factor to round to
fac2=`echo "scale=0 ; $fac/2" | bc`	# intfactor / 2

bvals=(`cat $1`)
nvals=${#bvals[@]}
for (( i=0; i<$nvals; i++ )) ; do
	oldval=${bvals[$i]}
	newval=`echo "scale=0 ; ($oldval+$fac2)/$fac*$fac" | bc`

	#echo $oldval $newval

	if [ $i == "0" ]; then 
		echo -n $newval > $2
	else
		echo -n " $newval" >> $2
	fi
done
echo " " >> $2

exit 0
