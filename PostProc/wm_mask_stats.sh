#!/bin/bash

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	filepath=$(echo ${i} | rev | cut -d'/' -f4- | rev )

	echo ${bblIDs}

	3dROIstats -mask /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/templates/PNC_template_wm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_FIT_ICVF_Std.nii.gz >>~/Mean_ICVF.txt
	3dROIstats -mask /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/templates/PNC_template_wm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_rtop_Std.nii.gz >>~/Mean_RTOP.txt	
	3dROIstats -mask /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/templates/PNC_template_wm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data${bblIDs}/${SubDate_and_ID}/norm/*_FA_Std.nii.gz >>~/Mean_FA.txt

done


