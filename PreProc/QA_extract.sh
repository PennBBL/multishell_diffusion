#!/bin/bash

# Get relevant b0 stats from ME's QA output into one csv

# Subject locations and loop
general=/data/jux/BBL/studies/grmpy/rawData/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	output=$(cat ~/grmpy/8_31_QA_grmpy/${bblIDs}*.qa|cut -f 2)
	meanRELrms=$(echo ${output}|cut -d' ' -f 7)
	meanABSrms=$(echo ${output}|cut -d' ' -f 6)
	tsnr0=$(echo ${output}|cut -d' ' -f 10)	
	tsnr300=$(echo ${output}|cut -d' ' -f 22)
	tsnr800=$(echo ${output}|cut -d' ' -f 34)
	tsnr2000=$(echo ${output}|cut -d' ' -f 46)		
	regurg=$(echo ${bblIDs}, ${tsnr0}, ${tsnr300}, ${tsnr800}, ${tsnr2000}, ${meanRELrms}, ${meanABSrms})
	echo $regurg
	echo $regurg >> ~/QAgrmpy_9_12.csv
done

