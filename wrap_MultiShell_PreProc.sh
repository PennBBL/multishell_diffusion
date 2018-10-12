#!/bin/bash

general=/data/jux/BBL/studies/grmpy/rawData/*/*

## Setup AMICO/NODDI (via pcook)				
matlab -nodisplay -r 'run /data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	prevrantest=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz
	if [ -f $prevrantest ]; then
		echo $bblIDs "already ran. You can use the time this if/then statement saved you to compliment the person sitting next to you, or to get a real job."
	else
		## Create log directory
		logDir=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/logfiles
		mkdir -p ${logDir}

		## Write subject-specific script for qsub
		var0="pushd /data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/; ./MultiShell_PreProc.sh ${bblIDs} ${SubDate_and_ID}; popd"

		echo -e "${var0}" >> ${logDir}/run_MultiShell_PreProc_"${bblIDs}"_"${SubDate_and_ID}".sh

		subject_script=${logDir}/run_MultiShell_PreProc_"${bblIDs}"_"${SubDate_and_ID}".sh
	
		# chmod 775 ${subject_script}
 	
		## Execute qsub job for probtrackx2 runs for each subject 
		echo ${bblIDs}
		echo ${SubDate_and_ID}
		qsub -q all.q,basic.q -wd ${logDir} -l h_vmem=8G,s_vmem=7G ${subject_script}
	fi
done
