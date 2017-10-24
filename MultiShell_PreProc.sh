#!/bin/bash
#Runs nfitis thorugh QA, topup, and eddy. Calculates Diffusion space -> Structural space affine, uses this calculations and pre-existing antsCT folder affine to template, and warp to template. 

#Prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions).

#[a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

#Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

#Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9 for all except eddy, 5.0.5 in current version)

#assumed that you're only correcting one set of volumes (A>P phase encoded in original usage)

#eddy step requires more memory than default allocation of 3 G of RAM. Use at least -l h_vmem=3.5,s_vmem=3

general=/data/joy/BBL/studies/grmpy/rawData/81760/*/
scripts=/home/melliott/scripts
acqp=$1
indx=""	

# For AMICO/NODDI Running (via pcook)				
#matlab -nodisplay -r 'run /data/joy/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 
	
		
#wrapper

for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	inputnifti=$(echo ${i}DTI_MultiShell_117dir/nifti/*.nii.gz)
	unroundedbval=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bval)
	topupref=$(echo ${i}DTI_MultiShell_topup_ref/nifti/*.nii.gz)
	bvec=$(echo ${i}DTI_MultiShell_117dir/nifti/*.bvec)
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Prestats
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Prestats/QA
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Prestats/topup
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Prestats/Eddy
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/CoReg
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Norm
	mkdir /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO
	out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
	eddy_outdir=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/Prestats/Eddy

	mkdir -p ${eddy_outdir}
	
############ QA #################
# Add Mark Elliot's QA script path
	#PATH=$PATH:/home/melliott/scripts
# Import bval and bvec because I don't know how to wildcard in perl in generateAmicoM_AP.pl later on
	#cp $unroundedbval $out/Prestats/QA/
	#cp $bvec $out/Prestats/QA/${bblIDs}_${SubDate_and_ID}_bvec.bvec
	#mv $out/Prestats/QA/*.bvec $out/Prestats/QA/
# Round bvals up or down 5, corrects for scanner output error in bvals (not needed in v4)
	#$scripts/bval_rounder.sh $unroundedbval $out/Prestats/QA/${bblIDs}_${SubDate_and_ID}_roundedbval.bval 100
# Get quality assurance metrics on DTI data for each shell
	#$scripts/qa_dti_v4.sh $inputnifti $unroundedbval $bvec $out/Prestats/QA/${bblIDs}_${SubDate_and_ID}_dwi.qa 100

############# DISTORTION/MOTION CORRECTION ################
# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation	
	#fslroi $inputnifti $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_AP 0 1
# Extract b0 from P>A topup ref for topup calculation
	#fslroi $topupref $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_PA 0 1
# Merge b0s for topup calculation
	#fslmerge -t $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_b0s $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_AP $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_nodif_PA
# Run topup to calculate correction for field distortion
	#topup --imain=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_b0s.nii.gz --datain=$1 --out=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_my_topup --fout=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_my_field --iout=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_iout
# Actually correct field distortion
	#applytopup --imain=$inputnifti --datain=$1 --inindex=1 --topup=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_my_topup --out=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_applied --method=jac
# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	#fslmaths $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_iout.nii.gz -Tmean $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_mean_iout.nii.gz


# Brain extraction mask for eddy, -m makes binary mask
	#topup_mask=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_bet_mean_iout_point_2.nii.gz

	#bet $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_mean_iout.nii.gz ${topup_mask} -m -f 0.2

# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.
	#echo $indx > index.txt

# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, has taken >5 hours. More recent eddy correction available in more recent FSL versions	
	#/share/apps/fsl/5.0.5/bin/eddy --imain=$out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_topup_applied.nii.gz --mask=${topup_mask} --index=index.txt --acqp=$1 --bvecs=$bvec --bvals=$out/Prestats/QA/${bblIDs}_${SubDate_and_ID}_roundedbval.bval --out=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied.nii.gz
	
	#eddy_output=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied.nii.gz
	
# Mask eddy output using topup mask
	#fslmaths ${eddy_output} -mas $out/Prestats/topup/${bblIDs}_${SubDate_and_ID}_bet_mean_iout_point_2_mask.nii.gz $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_maskedG.nii.gz

# Mask eddy output using topup mask
	#fslroi $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_maskedG.nii.gz $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_masked_b0G.nii.gz 0 1
 	
 	#masked_b0=$eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_masked_b0G.nii.gz
########### COREGISTRATION ####################

# make white matter only mask from segmented T1 in prep for flirt BBR
	#fslmaths /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*_BrainSegmentation.nii.gz -thr 3 -uthr 3 $out/CoReg/${bblIDs}_${SubDate_and_ID}_Struct_WM.nii.gz
# use flirt to calculate diffusion -> structural translation 
	#flirt -cost bbr -wmseg $out/CoReg/${bblIDs}_${SubDate_and_ID}_Struct_WM.nii.gz -in ${masked_b0}.nii.gz -ref /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*_ExtractedBrain0N4.nii.gz -out $out/CoReg/flirt_BBR -dof 6 -omat $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructFSL.mat
# Convert FSL omat to Ras
	#c3d_affine_tool -src ${masked_b0} -ref /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/${SubDate_and_ID}/antsCT/*ExtractedBrain0N4.nii.gz $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructFSL.mat -fsl2ras -oitk $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
# Use Subject to template warp and affine from grmpy directory after Ras diffusion -> structural space affine to put eddied_bet_2 onto pnc template
	#antsApplyTransforms -e 3 -d 3 -i ${masked_b0} -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Norm/${bblIDs}_${SubDate_and_ID}_eddied_b0_template_spaceG.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat


################## AMICO/NODDI (as well as global initialize @ top, but only needs to be run once so I put it out of the for loop?) ################## 

#Generate Amico scheme (edit paths for files like mask and eddy output in generateAmicoM script)
#/data/joy/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/generateAmicoM_AP.pl $bblIDs $SubDate_and_ID

#Run Amico
/data/joy/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/scripts/runAmico.sh /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/runAMICO.m

# Translate and Warp Amico Outputs to Normalized Space (dependent on structural to template translation and warp already being calculated, sequence to structural calculated above)
antsApplyTransforms -e 3 -d 3 -i /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/NODDI/FIT_dir.nii -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Norm/${bblIDs}_${SubDate_and_ID}_Norm_FIT_dir.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
antsApplyTransforms -e 3 -d 3 -i /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/${SubDate_and_ID}/AMICO/NODDI/FIT_ICVF.nii -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Norm/${bblIDs}_${SubDate_and_ID}_Norm_FIT_ICVF.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
antsApplyTransforms -e 3 -d 3 -i /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/$SubDate_and_ID/AMICO/NODDI/FIT_ISOVF.nii -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Norm/${bblIDs}_${SubDate_and_ID}_Norm_FIT_ISOVF.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
antsApplyTransforms -e 3 -d 3 -i /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/$bblIDs/${SubDate_and_ID}/AMICO/NODDI/FIT_OD.nii -r /data/joy/BBL/studies/pnc/template/pnc_template_brain.nii.gz -o $out/Norm/${bblIDs}_${SubDate_and_ID}_Norm_FIT_OD.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/CoReg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat
done

