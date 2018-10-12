#!/bin/bash

general=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f9 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f10|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

	echo $i
	echo ${bblIDs}

	# JHU -> SeqSpace
	##antsApplyTransforms -e 3 -d 3 -i /home/apines/templates/JHU-ICBM-labels-2mm-PNC.nii.gz -r ${i}/coreg/*seqspaceWM.nii.gz -o ${i}/coreg/${bblIDs}_${SubDate_and_ID}_JHU_seqSpace.nii.gz -t [${i}/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat,1] -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject0Warp.nii.gz -t [/data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_SubjectToTemplate0GenericAffine.mat,1] --interpolation MultiLabel

	#antsApplyTransforms -e 3 -d 3 -i /home/apines/templates/JHU-ICBM-labels-2mm-PNC.nii.gz -r ${i}/coreg/*Struct_WM.nii.gz -o ${i}/coreg/${bblIDs}_${SubDate_and_ID}_JHU_seqSpace.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject0Warp.nii.gz -t [/data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_SubjectToTemplate0GenericAffine.mat,1]

## 

	3dROIstats -mask ${i}/coreg/${bblIDs}_${SubDate_and_ID}_JHU_seqSpace.nii.gz -1DRformat ${i}/AMICO/NODDI/*ICVF* >> ~/tmp_ICVF.txt

	3dROIstats -mask ${i}/coreg/${bblIDs}_${SubDate_and_ID}_JHU_seqSpace.nii.gz -1DRformat ${i}/coreg/*_Camino_FA.nii.gz >> ~/tmp_FA.txt

done


