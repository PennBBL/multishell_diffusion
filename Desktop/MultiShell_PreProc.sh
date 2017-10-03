#!/bin/bash
#Runs nfitis thorugh QA, topup, and Eddy. 

#Prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions).

#[a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

#Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

#Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9 for all except eddy, 5.0.5 in current version)

#assumed that you're only correcting one set of volumes (A>P phase encoded in original usage)

#eddy step requires more memory than default allocation of 3 G of RAM. Use at least -l h_vmem=3.5,s_vmem=3

general=/data/joy/BBL/studies/grmpy/rawData/127611/*/
acqp=$1
indx=""	
for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	inputnifti=$(echo ${i}DTI_MultiShell_117dir/nifti/*.nii.gz)
	unroundedbval=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bval)
	topupref=$(echo ${i}DTI_MultiShell_topup_ref/nifti/*.nii.gz)
	bvec=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bvec)
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/QA
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/Intermediate
	out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs
	
# Round bvals up or down 5, corrects for scanner output error in bvals	
	./bval_rounder.sh $unroundedbval $out/QA/roundedbval.bval 100
# Get quality assurance metrics on DTI data for each shell
	~/qa_dti_v3.sh $inputnifti $out/QA/roundedbval.bval $bvec $out/QA/dwi.qa
# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation
	fslroi $inputnifti $out/Intermediates/nodif_AP 0 1
# Extract b0 from P>A topup ref for topup calculation
	fslroi $topupref $out/Intermediates/nodif_PA 0 1
# Merge b0s for topup calculation
	fslmerge -t $out/Intermediates/b0s $out/Intermediates/nodif_AP $out/Intermediates/nodif_PA
# Run topup to calculate correction for field distortion
	topup --imain=$out/Intermediates/b0s.nii.gz --datain=$1 --config=b02b0.cnf --out=$out/Intermediates/my_topup --fout=$out/Intermediates/my_field --iout=$out/Intermediates/topup_iout
# Actually correct field distortion
	applytopup --imain=$inputnifti --datain=$1 --inindex=1 --topup=$out/Intermediates/my_topup --out=$out/Intermediates/topup_applied --method=jac
# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	fslmaths $out/Intermediates/topup_iout.nii.gz -Tmean $out/Intermediates/mean_iout.nii.gz
# Brain extraction mask for eddy, -m makes binary mask
	bet $out/Intermediates/mean_iout.nii.gz $out/Intermediates/bet_iout -m
# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.
	echo $indx > index.txt
# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, has taken >5 hours. More recent eddy correction available in more recent FSL versions
	/share/apps/fsl/5.0.5/bin/eddy --imain=$out/Intermediates/topup_applied.nii.gz --mask=$out/Intermediates/bet_iout.nii.gz --index=index.txt --acqp=$1 --bvecs=$bvec --bvals=roundedbval.bval --out=$out/eddied

done
