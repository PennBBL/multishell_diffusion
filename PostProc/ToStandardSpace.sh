#!/bin/bash

# Just the ants transforms from multishell_prepoc - 6/19 update

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

### DTI
## single shell
	# fa -> Template

	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssFA.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_ssFA_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# md -> Template

	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssMD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_ssMD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# ad -> Template
	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssAD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_ssAD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# rd -> Template
	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssRD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_ssRD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

## multishell

	# fa -> Template

	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msFA.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_msFA_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# md -> Template

	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msMD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_msMD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# ad -> Template
	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msAD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_msAD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# rd -> Template
	antsApplyTransforms -e 3 -d 3 -i $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msRD.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_msRD_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

### NODDI

	# odi -> template
	antsApplyTransforms -e 3 -d 3 -i $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz -r ~/templates/PNCtemplate2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_ODI_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# icvf -> template
	antsApplyTransforms -e 3 -d 3 -i $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz -r ~/templates/PNCtemplate2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_ICVF_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
	
	# isovf -> template
	antsApplyTransforms -e 3 -d 3 -i $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF.nii.gz -r ~/templates/PNCtemplate2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_ISOVF_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat


### MAPL

# rtop -> Template
	antsApplyTransforms -e 3 -d 3 -i $eddy_outdir/${bblIDs}_${SubDate_and_ID}_rtop.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_rtop_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

# rtap -> Template
	antsApplyTransforms -e 3 -d 3 -i $eddy_outdir/${bblIDs}_${SubDate_and_ID}_rtap.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_rtap_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

# rtpp -> Template
	antsApplyTransforms -e 3 -d 3 -i $eddy_outdir/${bblIDs}_${SubDate_and_ID}_rtpp.nii.gz -r ${template} -o $out/norm/${bblIDs}_${SubDate_and_ID}_rtpp_Std.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat





