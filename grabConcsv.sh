#!/bin/bash

general=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*
cd /data/jux/BBL/projects/multishell_diffusion/GroupLevelAnalyses
for i in $general; do
	IDs=$(echo ${i}|cut -d'/' -f9)
	Dates=$(echo ${i}|cut -d'/' -f10)
	FA=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_FA.csv)
	ICVF=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_ICVF.csv)
	ODI=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_ODI.csv)	
	##b0meanABSrms=$(echo ${qa}|cut -d ',' -f1)
	SC=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/node_str_SC.csv)
	##b0meanRELrms=$(echo ${qa}|cut -d ',' -f2)
	##b0TSNR=$(echo ${qa}|cut d ' ' -f20)
	##echo ${IDs}	
	##echo $b0meanABSrms
	##echo $b0meanRELrms
	##b0TSNR=$(echo ${qa}|cut -d '	' -f3)
	##echo $b0TSNR
	#x="${IDs} , ${FA} , ${ICVF} , ${ODI}"	
	echo ${FA} >> ~/node_str_FA.txt
	echo ${ICVF} >> ~/node_str_ICVF.txt
	echo ${ODI} >> ~/node_str_ODI.txt
	echo ${SC} >> ~/node_str_SC.txt
done
