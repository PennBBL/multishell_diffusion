#!/bin/bash
#Runs nfitis thorugh QA, topup, and eddy. Calculates Diffusion space -> Structural space affine, uses this calculations and pre-existing antsCT folder affine to template, and warp to template. 

#Prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions).

#[a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

#Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

#Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9 for all except eddy, 5.0.5 in current version)

#assumed that you're only correcting one set of volumes (A>P phase encoded in original usage)

#eddy step requires more memory than default allocation of 3 G of RAM. Use at least -l h_vmem=3.5,s_vmem=3

general=/data/joy/BBL/studies/grmpy/rawData/*/*/
scripts=/home/melliott/scripts
acqp=$1
indx=""	

# For AMICO/NODDI Running (via pcook)

matlab -nodisplay -r "run '/data/joy/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m'"
exit

#wrapper

for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	inputnifti=$(echo ${i}DTI_MultiShell_117dir/nifti/*.nii.gz)
	unroundedbval=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bval)
	topupref=$(echo ${i}DTI_MultiShell_topup_ref/nifti/*.nii.gz)
	bvec=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bvec)
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/QA
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/Topup
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/Transforms
	out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs
# Import bvec
	cp $unroundedbval $out/QA/bvec.bvec	
# Round bvals up or down 5, corrects for scanner output error in bvals	
	$scripts/bval_rounder.sh $unroundedbval $out/QA/roundedbval.bval 100
# Get quality assurance metrics on DTI data for each shell
	$scripts/qa_dti_v3.sh $inputnifti $out/QA/roundedbval.bval $bvec $out/QA/dwi.qa
# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation	
	fslroi $inputnifti $out/Topup/nodif_AP 0 1
# Extract b0 from P>A topup ref for topup calculation
	fslroi $topupref $out/Topup/nodif_PA 0 1
# Merge b0s for topup calculation
	fslmerge -t $out/Topup/b0s $out/Topup/nodif_AP $out/Topup/nodif_PA
# Run topup to calculate correction for field distortion
	topup --imain=$out/Topup/b0s.nii.gz --datain=$1 --config=b02b0.cnf --out=$out/Topup/my_topup --fout=$out/Topup/my_field --iout=$out/Topup/topup_iout
# Actually correct field distortion
	applytopup --imain=$inputnifti --datain=$1 --inindex=1 --topup=$out/Topup/my_topup --out=$out/Topup/topup_applied --method=jac
# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	fslmaths $out/Topup/topup_iout.nii.gz -Tmean $out/Topup/mean_iout.nii.gz
# Brain extraction mask for eddy, -m makes binary mask
	bet $out/Topup/mean_iout.nii.gz $out/Topup/bet_iout_point_2 -m -f 0.2
# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.
	echo $indx > index.txt
# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, has taken >5 hours. More recent eddy correction available in more recent FSL versions
	/share/apps/fsl/5.0.5/bin/eddy --imain=$out/Topup/topup_applied.nii.gz --mask=$out/Topup/bet_iout_point_2.nii.gz --index=index.txt --acqp=$1 --bvecs=$bvec --bvals=$out/QA/roundedbval.bval --out=$out/eddied
# re-bet eddy output
	bet $out/eddied.nii.gz $out/eddied_bet_2.nii.gz -c 70 70 46 -R -m -f 0.2
# make white matter only mask from segmented T1 in prep for flirt BBR
        fslmaths /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/*/antsCT/*_BrainSegmentation.nii.gz -thr 3 -uthr 3 $out/Transforms/Struct_WM.nii.gz
# use flirt to calculate diffusion -> structural translation 
	flirt -cost bbr -wmseg $out/Transforms/Struct_WM.nii.gz -in $out/eddied_bet_2.nii.gz -ref /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/*/antsCT/*ExtractedBrain0N4.nii.gz -out $out/Transforms/flirt_BBR -dof 6 -omat $out/Transforms/MultiShDiff2StructFSL.mat
# Convert FSL omat to Ras
	c3d_affine_tool -src $out/eddied_bet_2.nii.gz -ref /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/*/antsCT/*ExtractedBrain0N4.nii.gz $out/Transforms/MultiShDiff2StructFSL.mat -fsl2ras -oitk $out/Transforms/MultiShDiff2StructRas.mat
# Use Subject to template warp and affine from grmpy directory after Ras diffusion -> structural space affine to put eddied_bet_2 onto pnc template
	antsApplyTransforms -e 3 -d 3 -i $out/eddied_bet_2.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Transforms/eddied_b0_template_space.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/*/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/*/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/Transforms/MultiShDiff2StructRas.mat

done

	
