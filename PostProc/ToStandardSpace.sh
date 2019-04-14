#!/bin/bash

# Just the ants transforms from multishell_prepoc

bblIDs=$1
SubDate_and_ID=$2

out=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}
general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/$bblIDs/$SubDate_and_ID
template=/data/jux/BBL/projects/xcpWorkshop/input/template/PNCtemplate2mm.nii.gz
eddy_outdir=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/eddy
	
	########################################################
	##       Non-NODDI Scalars to template space          ##
	########################################################
	echo "||||bringing scalars to template space||||"

	# Translate and Warp scalars to normalized Space (dependent on structural to template translation and warp already being calculated, sequence to structural calculated above)

	# rtop -> Template
	antsApplyTransforms -e 3 -d 3 -i $eddy_outdir/${bblIDs}_${SubDate_and_ID}_rtop.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_rtop_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# FA -> Template

	antsApplyTransforms -e 3 -d 3 -i $out/coreg/${bblIDs}_${SubDate_and_ID}_Camino_FA.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_FA_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat





