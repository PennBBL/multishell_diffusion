#!/bin/bash

general=/data/jux/BBL/studies/grmpy/rawData/*/*/


for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	input=/data/jux/BBL/studies/grmpy/rawData/${bblIDs}/${SubDate_and_ID}/
	output=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}
	if [ ! -d "${input}/DTI_MultiShell_117dir" ]; then
	rm -r ${output} 
	#else out=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
	#qaMask=$(ls ${out}/prestats/qa/*qamask.nii.gz)
	#qfilename=$(echo ${qaMask#$out/prestats/qa/})
	#mv ${qaMask} ${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_${qfilename}
	#clipMask=$(ls ${out}/prestats/qa/*clipmask.nii.gz)
	#cfilename=$(echo ${clipMask#$out/prestats/qa/})
	#mv ${clipMask} ${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_${cfilename}
	## Zip all nifti files
	#gzip -f ${out}/prestats/qa/*.nii
	fi
	


done

