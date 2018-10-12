#!/bin/sh
general=/data/joy/BBL/studies/grmpy/rawData/104235/*

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
tract_dir=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi
out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}

# get rid of unexplicably long DSI output file extensions
mv $tract_dir/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.fa0.nii.gz $tract_dir/${bblIDs}_${SubDate_and_ID}t1_maskedEddied_fa0.nii.gz
mv $tract_dir/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.adc.nii.gz $tract_dir/${bblIDs}_${SubDate_and_ID}t1_maskedEddied_adc.nii.gz

# FA -> Template
	antsApplyTransforms -e 3 -d 3 -i ${tract_dir}/${bblIDs}_${SubDate_and_ID}t1_maskedEddied_fa0.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_FA_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

# ADC/MD -> Template
	antsApplyTransforms -e 3 -d 3 -i ${tract_dir}/${bblIDs}_${SubDate_and_ID}t1_maskedEddied_adc.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_MD_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
done
