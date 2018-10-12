#!/bin/bash
#Runs nfitis thorugh QA, topup, and Eddy. 

#Prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions).

#[a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

#Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

#Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9 for all except eddy, 5.0.5 in current version)

general=/data/jux/BBL/studies/grmpy/rawData/93278/*/
scripts=/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts
acqp=$1
indx=""	
#echo>/data/jux/BBL/projects/multishell_diffusion/processedData/TSNR.csv
#for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	inputnifti=${i}DTI_MultiShell_117dir/nifti/*.nii.gz
	unroundedbval=${i}DTI_MultiShell_117dir/nifti/*.bval
	topupref=${i}DTI_MultiShell_topup_ref/nifti/*.nii.gz
	bvec=${i}DTI_MultiShell_117dir/nifti/*.bvec
	#mkdir /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}
	#mkdir /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/QA
	out=/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
	#echo -e /n>>/data/jux/BBL/projects/multishell_diffusion/processedData/TSNR.csv
	#echo ${bblIDs},>>/data/jux/BBL/projects/multishell_diffusion/processedData/TSNR.csv
# Round bvals up or down 5, corrects for scanner output error in bvals	
prevrantest=~/5_12_QA_grmpy/${bblIDs}.qa
	##if [ -f $prevrantest ]; then
		echo $bblIDs "already ran. You can use the time this if/then statement saved you to compliment the person sitting next to you, or to get a real job."
	##else	
	$scripts/bval_rounder.sh $unroundedbval $out/prestats/qa/roundedbval.bval 100
# Get quality assurance metrics on DTI data for each shell
	$scripts/qa_dti_v3.sh $inputnifti $out/prestats/qa/roundedbval.bval $bvec /home/apines/8_31_QA_grmpy/${bblIDs}.qa
##fi

done
