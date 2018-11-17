#!/bin/bash

# DSI just refers to dsi studio. Use it to run DSI calculations on this data, set to include FA and MD at the moment.

# Note that DSI uses a different orientation than the rest of the software included in these directories. Not a problem going in, but it will be coming out.

########################
###  Paths           ###
########################

dsiBin=/share/apps/dsistudio/2016-01-25/bin/dsi_studio
general=/data/joy/BBL/studies/grmpy/rawData/90060/*

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
	
out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}

############################################
### Define Tractography Output Directory ###
############################################
tract_dir=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/dsi

echo "Deterministic Tractography Output Directory"
echo ""
echo ${tract_dir}

##################################################################
### Define subject-specific Rotated bvecs and other DTI inputs ###
##################################################################
echo " "
echo "Subject-specific rotated bvecs file"
echo " "
echo ${bvec}

echo " "
echo "bval file"
echo " "
echo ${bval}

indexfile=/data/joy/BBL/projects/multishell_diffusion/processedData/index.txt
acqparams=/data/joy/BBL/projects/multishell_diffusion/processedData/acqpars.txt

##########################
### DTI Reconstruction ###
##########################
${dsiBin} --action=rec --thread=8 --source=${inputnifti} --method=1 # method is DTI or DSI consider other methods (GQI is what Preya is using)

# Rename DTI reconstruction file
reconstruction=$(ls "${tract_dir}"/*.fib.gz )

#########################################################
### Export the FA map from reconstruction (.fib) file ###
#########################################################

${dsiBin} --action=exp --source=${reconstruction} --export=fa0

#########################################################
### Export the MD map from reconstruction (.fib) file ###
#########################################################

${dsiBin} --action=exp --source=${reconstruction} --export=adc

#set atlas to subject space JHU
#gunzip ${out}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace.nii.gz
JHU_atlas_path=${out}/coreg/${bblIDs}_${SubDate_and_ID}_JHU2mm_diffspace.nii

### Export regional FA using JHU ROIs###

${dsiBin} --action=ana --source=${reconstruction} --atlas=${JHU_atlas_path} --export=fa0

done
