#!/bin/bash

# Runs nfitis thorugh qa, topup, and eddy. Calculates Diffusion space -> Structural space affine, uses this calculations and pre-existing antsCT folder affine to template, and warp to template. Runs AMICO, translates and warps AMICO output to template based on ants calculations. Can use a GPU for eddy processing if you have one available to you.

# acquisition parameters: a b c d (multiple rows for multiple phase encoding directions)
# [a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

# Needed inputs built-in to script: DWIs, bvecs, bvals, acquistion parameters, template brain, software/script locations (unrounded)

# eddy step requires more memory than default allocation of 3 G of RAM (h_vmem,s_vmem reccomended)

bblIDs=$1
SubDate_and_ID=$2
gpu=${3:-0}

if [ $# -eq 0 ]; then
echo "
Usage: MultiShell_PreProc_(version).sh <bblID> <SubDate_and_ID> <gpu_usage>"
echo "
For gpu usage enter '1' as the third argument.
"
exit
fi

general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/$bblIDs/$SubDate_and_ID
scripts=/data/joy/BBL/tutorials/code/multishell_diffusion/PreProc
acqp=/data/jux/BBL/projects/multishell_diffusion/processedData/acqpars.txt
template=/data/jux/BBL/projects/xcpWorkshop/input/template/PNCtemplate2mm.nii.gz
slspec=/data/jux/BBL/projects/multishell_diffusion/processedData/slspec.txt


# for GPU Usage

export LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH

# Initialize AMICO				
matlab -nodisplay -r 'run /data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 
	
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	inputnifti=$(echo $general/DTI_MultiShell_117dir/nifti/*.nii.gz)
	unroundedbval=$(echo $general/DTI_MultiShell_117dir/nifti/*.bval)
	topupref=$(echo $general/DTI_MultiShell_topup_ref/nifti/*.nii.gz)
	bvec=$(echo $general/DTI_MultiShell_117dir/nifti/*.bvec)
	indx=""

# Make directory structure
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/qa
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/topup
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/eddy
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/coreg
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/norm
	mkdir /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/AMICO

	out=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}
	eddy_outdir=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/eddy

	mkdir -p ${eddy_outdir}

	#################################
	##            qa               ##
	#################################
	echo "||||running quality assurance||||"


	# Import bval and bvec
	cp $unroundedbval $out/prestats/qa/
	cp $bvec $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_bvec.bvec

	# Round bvals up or down 5, corrects for scanner output error in bvals
	$scripts/bval_rounder.sh $unroundedbval $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval 100
	# Get quality assurance metrics on DTI data for each shell
	$scripts/qa_dti_v3.sh $inputnifti $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval $bvec $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_dwi.qa 
	
	# Zip all nifti files
	gzip -f ${out}/prestats/qa/*.nii

	# Rename clipmask
	clipMask=$(ls ${out}/prestats/qa/*clipmask.nii.gz)
	cfilename=$(echo ${clipMask#$out/prestats/qa/})

	mv ${clipMask} ${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_${cfilename}

	## Rename qa mask
	qaMask=$(ls ${out}/prestats/qa/*qamask.nii.gz)
	qfilename=$(echo ${qaMask#$out/prestats/qa/})

	mv ${qaMask} ${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_${qfilename}

	###########################################################
	##              DISTORTION/MOTION CORRECTION             ##
	###########################################################
	echo "||||running topup||||"

	# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation	
	fslroi $inputnifti $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_AP 0 1

	# Extract b0 from P>A topup ref for topup calculation
	fslroi $topupref $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_PA 0 1

	# Merge b0s for topup calculation
	fslmerge -t $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_b0s $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_AP $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_PA

	# Run topup to calculate correction for field distortion
	topup --imain=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_b0s.nii.gz --datain=$acqp --out=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup --fout=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_field --iout=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_iout

	# Actually correct field distortion
	applytopup --imain=$inputnifti --datain=$acqp --inindex=1 --topup=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup --out=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_applied --method=jac

	# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	fslmaths $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_iout.nii.gz -Tmean $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_mean_iout.nii.gz

	# Brain extraction mask for eddy, -m makes binary mask
	topup_mask=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_bet_mean_iout_point_2.nii.gz

	bet $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_mean_iout.nii.gz ${topup_mask} -m -f 0.2

	# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.)
	echo $indx > ~/index.txt

	# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, has taken >5 hours per subject. 
	
	echo "||||running eddy current correction||||"

	if [ $gpu -eq 1 ]; then
		echo "|||--GPU version--|||"
		/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/eddy_cuda --imain=${inputnifti} --mask=${topup_mask} --index=/data/jux/BBL/projects/multishell_diffusion/processedData/index.txt --acqp=${acqp} --bvecs=${bvec} --bvals=${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval --topup=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup --repol --out=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_gpu_sls --ol_type=both --mporder=10 --slspec=${slspec}
		eddy_output=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_gpu_sls.nii.gz
	else
		echo "|||--non-GPU version--|||"
		/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/eddy_openmp --imain=${inputnifti} --mask=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_bet_mean_iout_point_2_mask.nii.gz --index=/data/jux/BBL/projects/multishell_diffusion/processedData/index.txt --acqp=${acqp} --bvecs=${bvec} --bvals=${out}/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval --ol_type=both --mb=4 --topup=$out/prestats/topup/${bblIDs}_${SubDate_and_ID}_topup --repol --out=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_sls 
		eddy_output=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_sls.nii.gz

	fi
	
	# Mask eddy output using topup mask, make first b0 only for coreg
	fslmaths ${eddy_output} -mas $out/prestats/topup/${bblIDs}_${SubDate_and_ID}_bet_mean_iout_point_2_mask.nii.gz $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked.nii.gz

	fslroi $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked.nii.gz $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz 0 1
	 	
	masked_b0=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz

	##############################################
	###           coregistration 		   ###
	##############################################
	echo "||||executing coregistration||||"

	# make white matter only mask from segmented T1 in prep for flirt BBR
	fslmaths /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*_BrainSegmentation.nii.gz -thr 3 -uthr 3 $out/coreg/${bblIDs}_${SubDate_and_ID}_Struct_WM.nii.gz

	# use flirt to calculate diffusion -> structural translation 
	flirt -cost bbr -wmseg $out/coreg/${bblIDs}_${SubDate_and_ID}_Struct_WM.nii.gz -in ${masked_b0}.nii.gz -ref /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*_ExtractedBrain0N4.nii.gz -out $out/coreg/${bblIDs}_${SubDate_and_ID}_flirt_BBR -dof 6 -omat $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructFSL.mat

	# Convert FSL omat to Ras
	c3d_affine_tool -src ${masked_b0} -ref /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/${SubDate_and_ID}/antsCT/*ExtractedBrain0N4.nii.gz $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructFSL.mat -fsl2ras -oitk $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# Use Subject to template warp and affine from grmpy directory after Ras diffusion -> structural space affine to put eddied_bet_2 onto pnc template
	antsApplyTransforms -e 3 -d 3 -i ${masked_b0} -r ${template} -o $out/coreg/${bblIDs}_${SubDate_and_ID}_eddied_b0_template_space.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# Take T1 generated mask to sequence (diffusion) space
	antsApplyTransforms -e 3 -d 3 -i /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_BrainExtractionMask.nii.gz -r /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz -o $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz -t [/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat,1] -n NearestNeighbor

	#remask eddy output using T1 space generated mask

	fslmaths ${eddy_output} -mas $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_t1Masked.nii.gz


	########################################################
	###               DT MODEL FITS			     ###
	########################################################
	echo "||||Fitting DTI with mrtrix3||||"

	echo "||||Unishell fit||||"
	dwiextract  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.nii.gz -fslgrad  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.eddy_rotated_bvecs $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval -shell 0,800 - |dwi2tensor -mask  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_b800_fit.nii.gz

	# Calculate metrics
	
	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_b800_fit.nii.gz -adc - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssMD.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_b800_fit.nii.gz -fa - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssFA.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_b800_fit.nii.gz -rd - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssRD.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_b800_fit.nii.gz -ad - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_ssAD.nii.gz

	echo "||||Multishell fit||||"
	dwiextract  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.nii.gz -fslgrad  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.eddy_rotated_bvecs $out/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval -shell 0,300,800,2000 - |dwi2tensor -mask  $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_multishell_fit.nii.gz

	# Calculate metrics
	
	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_multishell_fit.nii.gz -adc - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msMD.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_multishell_fit.nii.gz -fa - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msFA.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_multishell_fit.nii.gz -rd - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msRD.nii.gz

	tensor2metric $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_mrtr_multishell_fit.nii.gz -ad - |mrconvert -force -stride -1,2,3 - $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_msAD.nii.gz

	########################################################
	###                AMICO/NODDI			     ###
	########################################################
	echo "||||running NODDI via AMICO||||"

	# Generate AMICO scheme (edit paths for files like mask and eddy output in generateamicoM script)
	/data/joy/BBL/tutorials/code/multishell_diffusion/PreProc/generateAmicoM_AP.pl $bblIDs $SubDate_and_ID

	# Run AMICO
	#/data/joy/BBL/tutorials/code/multishell_diffusion/PreProc/runAmico.sh ${out}/AMICO/runAMICO.m
	
	# Set NODDI Dir
	NODDIdir=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI
	
	# Zip and rename native space NODDI outputs to subejct specific
	gzip $NODDIdir/*.nii
	mv $NODDIdir/FIT_dir.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz 
	mv $NODDIdir/FIT_ICVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz 
	mv $NODDIdir/FIT_ISOVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF.nii.gz 
	mv $NODDIdir/FIT_OD.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz 

	# Add Simlinks
	ln -s ${template} $out/norm/
	ln -s ${template} $out/coreg/
	ln -s $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz $out/coreg
	ln -s /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_BrainExtractionMask.nii.gz $out/coreg/
	ln -s /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_ExtractedBrain0N4.nii.gz $out/coreg/

	###################################
	###         Cleanup             ###
	###################################

rm $out/AMICO/*.nii*
rm $out/AMICO/bvals
rm $out/AMICO/bvecs



