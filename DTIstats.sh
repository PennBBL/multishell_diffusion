#!/bin/bash

#downsample FA and MD output to 2MM, grab DTI (FA and WM) stats

#JHU

# Subject locations and loop
general=/data/joy/BBL/studies/grmpy/rawData/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}

#FA
#antsApplyTransforms -e 0 -d 3 -i ${out}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o ${out}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace_ds.nii.gz -n MultiLabel

#3dROIstats -mask ${out}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace.nii.gz -1Dformat /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.fa0.nii.gz >> FA_all

#MD
#antsApplyTransforms -e 3 -d 3 -i /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.adc.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied2mm.src.gz.fy.dti.fib.gz.adc.nii.gz -n MultiLabel

3dROIstats -mask /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace.nii.gz -1DRformat /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz >> JHU_ODI_all

done
