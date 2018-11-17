#!/bin/bash

# fslstats to grab vol from brain mask

# Subject locations and loop
general=/data/jux/BBL/studies/grmpy/rawData/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

	vol=$(fslstats /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/coreg/${bblIDs}_${SubDate_and_ID}_BrainExtractionMask.nii.gz -V)
	x=$(echo $bblIDs, $vol)
	echo $x
	echo $x >> ~/grmpyvols.csv
done