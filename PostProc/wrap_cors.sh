#!/bin/bash
# wrapper to correlate scalars within each subject

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
 	
		## Execute qsub job for each subject
		echo ${bblIDs}
		echo ${SubDate_and_ID}
		logDir=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/logfiles

		qsub -S /data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python3 /data/joy/BBL/tutorials/code/multishell_diffusion/PostProc/correlate_scalars.py ${bblIDs} ${SubDate_and_ID}

		# added because append was causing overwriting
		sleep 6s
done
