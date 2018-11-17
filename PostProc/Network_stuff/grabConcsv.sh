#!/bin/bash

# Used to copy individual connectivity .csv's into group .txt file

general=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*
cd /data/jux/BBL/projects/multishell_diffusion/GroupLevelAnalyses
for i in $general; do
	IDs=$(echo ${i}|cut -d'/' -f9)
	Dates=$(echo ${i}|cut -d'/' -f10)
	FA=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_FA.csv)
	ICVF=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_ICVF.csv)
	ODI=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_ODI.csv)	

	SC=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_SC.csv)

	echo ${FA} >> ~/node_str_FA.txt
	echo ${ICVF} >> ~/node_str_ICVF.txt
	echo ${ODI} >> ~/node_str_ODI.txt
	echo ${SC} >> ~/node_str_SC.txt
done
