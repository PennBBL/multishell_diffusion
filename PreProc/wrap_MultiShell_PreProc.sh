#!/bin/bash

# to wrap Multishell preproc and run on seperate qsubs

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

## Setup AMICO/NODDI				
matlab -nodisplay -r 'run /data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	prevrantest=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz
	if [ -f $prevrantest ]; then
		echo $bblIDs "already ran. You can use the time this if/then statement saved you to compliment the person sitting next to you, or to get a real job."
	else
		## Create log directory
		mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}
		mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}
		logDir=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/logfiles
		mkdir -p ${logDir}

		## Write subject-specific script for qsub
		var0="pushd /data/joy/BBL/tutorials/code/multishell_diffusion/PreProc; ./MultiShell_PreProc.sh ${bblIDs} ${SubDate_and_ID}; popd"

		echo -e "${var0}" >> ${logDir}/run_MultiShell_PreProc_"${bblIDs}"_"${SubDate_and_ID}".sh

		subject_script=${logDir}/run_MultiShell_PreProc_"${bblIDs}"_"${SubDate_and_ID}".sh
	
		# chmod 775 ${subject_script}
 	
		## Execute qsub job runs for each subject 
		echo ${bblIDs}
		echo ${SubDate_and_ID}
		qsub -q all.q,basic.q -wd ${logDir} -l h_vmem=8G,s_vmem=7G ${subject_script}
	fi
done
