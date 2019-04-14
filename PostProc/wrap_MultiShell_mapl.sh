#!/bin/bash

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
 	
		## Execute qsub job for mapl for each subject
		echo ${bblIDs}
		echo ${SubDate_and_ID}

		#mapl with extrap in this iteration
		qsub -S /data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python -q all.q,basic.q -l h_vmem=12G,s_vmem=11G /data/joy/BBL/tutorials/code/multishell_diffusion/PostProc/mapl.py ${bblIDs} ${SubDate_and_ID}

done
