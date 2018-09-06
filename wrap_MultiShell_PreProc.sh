#!/bin/bash
gpu=${1:-0}
general=/data/jux/BBL/studies/grmpy/rawData/*/*

## Setup AMICO/NODDI (via pcook)				
##matlab -nodisplay -r 'run /data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	prevrantest=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.nii.gz
	if [ -f $prevrantest ]; then
		echo $bblIDs "already ran. You can use the time this saved you to compliment the person sitting next to you, or to get a real job."
	else
		## Create log directory
		logDir=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/logfiles
		mkdir -p ${logDir}

		## Write subject-specific script for qsub
	if [ $gpu -eq 1 ]; then		
	var0="~/multishell_diffusion/MultiShell_PreProc.sh ${bblIDs} ${SubDate_and_ID} 1"
	else
	var0="~/multishell_diffusion/MultiShell_PreProc.sh ${bblIDs} ${SubDate_and_ID}"
	fi
		echo -e "${var0}" > ${logDir}/run_MultiShell_PreProc_"${bblIDs}"_"${SubDate_and_ID}".sh

		subject_script=${logDir}/run_MultiShell_PreProc_${bblIDs}_${SubDate_and_ID}.sh
	
		# chmod 775 ${subject_script}
 	
		## Execute qsub job for each subject 
		echo ${bblIDs}
		echo ${SubDate_and_ID}
		qsub -q all.q,basic.q -wd ${logDir} -l h_vmem=14G,s_vmem=13G ${subject_script}
	fi
done
