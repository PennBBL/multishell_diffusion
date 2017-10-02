#!/bin/bash
#Runs nfitis thorugh QA, topup, and Eddy. 

#Prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions).

#[a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

#Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

#Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9 for all except eddy, 5.0.5 in current version

#assumed that you're only correcting one set of volumes (A>P phase encoded in original usage)

general=/data/joy/BBL/studies/grmpy/rawData/127611/*/
acqp=$1
indx=""	
for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

for i in $general;do 
	inputnifti=$(echo ${i}DTI_MultiShell_117dir/nifti/*.nii.gz)
	unroundedbval=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bval)
	topupref=$(echo ${i}DTI_MultiShell_topup_ref/nifti/*.nii.gz)
	bvec=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bvec)
	
# Round bvals up or down 5, corrects for scanner output error in bvals	
	/home/melliott/scripts/bval_rounder.sh $unroundedbval roundedbval.bval 100
# Get quality assurance metrics on DTI data for each shell
	~/qa_dti_v3.sh $inputnifti roundedbval.bval $bvec dwi.qa
# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation
	fslroi $inputnifti nodif_AP 0 1
# Extract b0 from P>A topup ref for topup calculation
	fslroi $topupref nodif_PA 0 1
# Merge b0s for topup calculation
	fslmerge -t b0s nodif_AP nodif_PA
# Run topup to calculate correction for field distortion
	topup --imain=b0s.nii.gz --datain=$1 --out=my_topup --fout=my_field --iout=topup_iout
# Actually correct field distortion
	applytopup --imain=$inputnifti --datain=$1 --inindex=1 --topup=my_topup --out=topup_applied --method=jac
# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	fslmaths topup_iout.nii.gz -Tmean mean_iout.nii.gz
# Brain extraction mask for eddy, -m makes binary mask
	bet mean_iout.nii.gz bet_iout -m
# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.
	echo $indx > index.txt
# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, takes 1-3 hours. More recent eddy correction available in more recent FSL versions
	/share/apps/fsl/5.0.5/bin/eddy --imain=topup_applied.nii.gz --mask=bet_iout.nii.gz --index=index.txt --acqp=$1 --bvecs=$bvec --bvals=roundedbval.bval --out=eddied

done

	
	

