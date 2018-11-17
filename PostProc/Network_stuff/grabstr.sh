#!/bin/bash

general=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/2*
cd /data/jux/BBL/projects/multishell_diffusion/GroupLevelAnalyses
for i in $general; do
	IDs=$(echo ${i}|cut -d'/' -f9)
	Dates=$(echo ${i}|cut -d'/' -f10)
	is=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/ICVFstr.csv)
	icvf=$(echo ${is})
	echo $icvf	
	###b0meanRELrms=$(echo ${qa}|cut -d ',' -f2)
	##b0TSNR=$(echo ${qa}|cut d ' ' -f20)
	##echo ${IDs}	
	#echo $b0meanABSrms
	#echo $b0meanRELrms
	##b0TSNR=$(echo ${qa}|cut -d '	' -f3)
	##echo $b0TSNR
	#x="${IDs} , ${b0meanABSrms}"
	#echo ${x}	
	#echo ${x} >> ~/icvfSTR.txt
	if=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/FAstr.csv)
	fa=$(echo ${if}|cut -d ',' -f1)
	###b0meanRELrms=$(echo ${qa}|cut -d ',' -f2)
	##b0TSNR=$(echo ${qa}|cut d ' ' -f20)
	##echo ${IDs}	
	##echo $b0meanABSrms
	##echo $b0meanRELrms
	##b0TSNR=$(echo ${qa}|cut -d '	' -f3)
	##echo $b0TSNR
	#x="${IDs} , ${b0meanABSrms}"
	##echo ${x}	
	##echo ${x} >> ~/faSTR.txt
	io=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/ODIstr.csv)
	odi=$(echo ${io}|cut -d ',' -f1)
	###b0meanRELrms=$(echo ${qa}|cut -d ',' -f2)
	##b0TSNR=$(echo ${qa}|cut d ' ' -f20)
	##echo ${IDs}	
	##echo $b0meanABSrms
	##echo $b0meanRELrms
	##b0TSNR=$(echo ${qa}|cut -d '	' -f3)
	##echo $b0TSNR
	#x="${IDs} , ${b0meanABSrms}"
	#echo ${x}	
	#echo ${x} >> ~/icvfSTR.txt
	isc=$(cat /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${IDs}/${Dates}/tractography/SCstr.csv)
	sc=$(echo ${isc}|cut -d ',' -f1)
	###b0meanRELrms=$(echo ${qa}|cut -d ',' -f2)
	##b0TSNR=$(echo ${qa}|cut d ' ' -f20)
	##echo ${IDs}	
	echo $b0meanABSrms
	echo $b0meanRELrms
	##b0TSNR=$(echo ${qa}|cut -d '	' -f3)
	##echo $b0TSNR
	x="${IDs} , ${fa} , ${icvf}, ${odi}, ${sc}"
	echo ${x}	
	echo ${x} >> ~/STR.txt
done
