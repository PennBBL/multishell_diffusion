#!/bin/bash

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	filepath=$(echo ${i} | rev | cut -d'/' -f4- | rev )

	echo ${bblIDs}

	# Mean values from NODDI scalars
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_ODI_Std.nii.gz >>~/ODI_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_FIT_ICVF_Std.nii.gz >>~/ICVF_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_FIT_ISOVF_Std.nii.gz >>~/ISOVF_mean_wm.txt

	# Mean values from MAPL scalars
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_rtop_Std.nii.gz >>~/rtop_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_rtap_Std.nii.gz >>~/rtap_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_rtpp_Std.nii.gz >>~/rtpp_mean_wm.txt

	# Mean Values from single shell DT scalars
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_ssMD_Std.nii.gz >>~/ss_MD_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_ssFA_Std.nii.gz >>~/ss_FA_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_ssAD_Std.nii.gz >>~/ss_AD_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_ssRD_Std.nii.gz >>~/ss_RD_mean_wm.txt
	
	# Mean Values from multishell DT scalars
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_msMD_Std.nii.gz >>~/ms_MD_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_msFA_Std.nii.gz >>~/ms_FA_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_msAD_Std.nii.gz >>~/ms_AD_mean_wm.txt
	3dROIstats -mask ~/templates/pnc_wm_prior_bin2mm.nii.gz -1DRformat -nomeanout -nzmean ${filepath}/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm/*_msRD_Std.nii.gz >>~/ms_RD_mean_wm.txt

done


