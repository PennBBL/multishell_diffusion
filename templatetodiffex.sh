#!/bin/bash

dsiBin=/share/apps/dsistudio/2016-01-25/bin/dsi_studio
general=/data/joy/BBL/studies/grmpy/rawData/*/*

# Subject locations and loop
for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

# Input file locations
	inputnifti=$(echo /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz)
	bval=$(echo /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/qa/*roundedbval.bval)
	bvec=$(echo /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy/*eddied.eddy_rotated_bvecs)
	eddy_outdir=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy
	out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}

#template to d space
antsApplyTransforms -e 0 -d 3 -i ~/pncTemplateJLF_Labels2mm.nii.gz -r $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz -o ${out}/coreg/${bblIDs}_${SubDate_and_ID}_JLF_diffspace.nii.gz -n NearestNeighbor -t [$out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat, 1] -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject1GenericAffine.mat -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject0Warp.nii.gz

done

#-t [$out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat, 1]
