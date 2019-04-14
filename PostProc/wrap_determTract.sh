#!/bin/bash

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	logDir=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/logfiles

		## Write subject-specific script for qsub
		var0="pushd /data/joy/BBL/tutorials/code/multishell_diffusion/PostProc; ./determTract.sh ${bblIDs} ${SubDate_and_ID}; popd"

		echo -e "${var0}" > ${logDir}/run_determTract_"${bblIDs}"_"${SubDate_and_ID}".sh

		subject_script=${logDir}/run_determTract_"${bblIDs}"_"${SubDate_and_ID}".sh
 	
		## Execute qsub jobs for each subject 
		echo ${bblIDs}
		echo ${SubDate_and_ID}
		qsub -q all.q,basic.q -wd ${logDir} -l h_vmem=8G,s_vmem=7G ${subject_script}
#fi
done
