#!/bin/bash

#KD_LL Version, pre HCP

# Runs nfitis thorugh qa, topup, and eddy. Calculates Diffusion space -> Structural space affine, uses this calculations and pre-existing antsCT folder affine to template, and warp to template. Runs AMICO, translates and warps AMICO output to template based on ants calculations

# No more prompted input: acquisition parameters a b c d (multiple rows for multiple phase encoding directions) in previous versions.

# [a b c d] - a, b, and c are to indicate phase encoding direction. 0 1 0 =  posterior -> anterior. -1 would indicate A>P. d is a calculation based off the echo spacing and epi factor d=((10^-3)*(echo spacing)*(epi factor). See https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/topup/Faq for detail.

# Needed inputs built-in to script: .nii, .bvecs, .bvals (unrounded)

# Needs access to following scripts: qa_clipcount_v3.sh, qa_dti_v3.sh, qa_motion_v3.sh, qa_preamble.sh, qa_tsnr_v3.sh, as well as fsl scripts (5.0.9)

# assumed that you're only correcting one set of volumes (A>P phase encoded in original usage)

# eddy step requires more memory than default allocation of 3 G of RAM (h_vmem,s_vmem reccomended)

# uses fsl 5.0.9 and 5.0.9 eddy patch

IDs=$1

general=/data/jux/daviska/3T_Subjects/$IDs
scripts=/home/melliott/scripts
acqp=~/acqpkd.txt
indx=""	

# For AMICO/NODDI Running (via pcook)				
matlab -nodisplay -r 'run /data/jux/daviska/apines/amicoSYRP/scripts/amicoGlobalInitialize.m' -r 'exit' 
	
		
# wrapper

#for ((i=1; i<119; i+=1)); do indx="$indx 1"; done

#for i in $general;do 
	#bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);*
	#SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	#Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	#ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)
	#inputnifti=$(echo $general/DTI_MultiShell_117dir/nifti/*.nii.gz)
	#topupref=$(echo $general/DTI_MultiShell_topup_ref/nifti/*.nii.gz)

#	Clean up old files
	###rm -r /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc
	rm -r /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/AMICO/
# Make directory structure
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Phase
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Magnitude
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/qa
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/eddy
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg
	mkdir /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/norm

	out=/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}
	eddy_outdir=/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/eddy

	#################################
	##            qa               ##
	#################################

	# Add Mark Elliot's qa script path
	PATH=$PATH:/home/melliott/scripts

	# Merge all Shells into one nifti because that's what I'm used to and change is scary

		#b2000 shell
	
	#cp $general/NODDI_B_2000_Series*/* /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
	#cd /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
	#series=/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/*
	#for i in $series; do 
	#	dicomspaces=$(echo ${i}|cut -d'/' -f10 |sed s@'/'@' '@g)
#		dicom=$(echo ${dicomspaces}|cut -d ' ' -f2|cut -d '(' -f2|cut -d ')' -f1)_2000
#		echo $dicom
#		mv "${i}" "/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/${dicom}"
#		done
#	rm /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/00*

		#b300 shell	

#	cp $general/NODDI_B_300_Series*/* /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
#	series=/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/*
#	for i in $series; do 
#		dicomspaces=$(echo ${i}|cut -d'/' -f10 |sed s@'/'@' '@g)
#		dicom=$(echo ${dicomspaces}|cut -d ' ' -f2|cut -d '(' -f2|cut -d ')' -f1)_300
#		mv "${i}" "/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/${dicom}"
#		done
#	rm /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/00*

		#b700 shell

#	cp $general/NODDI_B_700_Series*/* /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
#	series=/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/*
#	for i in $series; do 
#		dicomspaces=$(echo ${i}|cut -d'/' -f10 |sed s@'/'@' '@g)
#		dicom=$(echo ${dicomspaces}|cut -d ' ' -f2|cut -d '(' -f2|cut -d ')' -f1)_700
#		mv "${i}" "/data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/${dicom}"
#		done
#	rm /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/00*
#	rm /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/core*
#	rm /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/core*
#	cd /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells
#	dcm2nii *

#	fslmerge -t ${out}/unproc/${IDs}_MultiShell_Merged.nii.gz /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/shells/*.nii.gz
#	inputnifti=${out}/unproc/${IDs}_MultiShell_Merged.nii.gz	

	# Merge corresponding .bval and .bvec files	
#	paste -d"\0" ${out}/unproc/shells/*.bvec >> ${out}/unproc/bvecs
#	paste -d"\0" ${out}/unproc/shells/*.bval >> ${out}/unproc/bvals

#	unroundedbval=$(echo ${out}/unproc/bvals)
#	bvec=$(echo ${out}/unproc/bvecs)

	# Round bvals up or down 5, corrects for scanner output error in bvals (not needed in v4)
#	$scripts/bval_rounder.sh $unroundedbval $out/prestats/qa/${IDs}_roundedbval.bval 100

	# Get quality assurance metrics on DTI data for each shell
#	 $scripts/qa_dti_v3.sh $inputnifti $out/prestats/qa/${IDs}_roundedbval.bval $bvec $out/prestats/qa/${IDs}_dwi.qa 	
	
	# Get quality assurance metrics on DTI data for each shell with v4
	##$scripts/qa_dti_v4.sh $inputnifti $unroundedbval $bvec 100 $out/prestats/qa/${IDs}_${SubDate_and_ID}_dwi.qa 
	
	# Rename clipmask
	##clipMask=$(ls ${out}/prestats/qa/*clipmask.nii.gz)
	##cfilename=$(echo ${clipMask$out/prestats/qa/})

	##mv ${clipMask} ${out}/prestats/qa/${IDs}_${SubDate_and_ID}_${cfilename}

	## Rename qa mask
	##qaMask=$(ls ${out}/prestats/qa/*qamask.nii.gz)
	##qfilename=$(echo ${qaMask$out/prestats/qa/})

	##mv ${qaMask} ${out}/prestats/qa/${IDs}_${SubDate_and_ID}_${qfilename}

	## Zip all nifti files
#	gzip -f ${out}/prestats/qa/*.nii
	
	###########################################################
	##           EDDY DISTORTION/MOTION CORRECTION           ##
	###########################################################

	# Extract b0 from anterior to posterior phase-encoded input nifti for topup calculation	
	#fslroi $inputnifti $out/prestats/topup/${IDs}_nodif_AP 0 1

	# Extract b0 from P>A topup ref for topup calculation
	#fslroi $topupref $out/prestats/topup/${IDs}_${SubDate_and_ID}_nodif_PA 0 1

	# Merge b0s for topup calculation
	#fslmerge -t $out/prestats/topup/${IDs}_${SubDate_and_ID}_b0s $out/prestats/topup/${IDs}_${SubDate_and_ID}_nodif_AP $out/prestats/topup/${IDs}_${SubDate_and_ID}_nodif_PA

	# Run topup to calculate correction for field distortion
	#topup --imain=$out/prestats/topup/${IDs}_${SubDate_and_ID}_b0s.nii.gz --datain=$acqp --out=$out/prestats/topup/${IDs}_${SubDate_and_ID}_topup --fout=$out/prestats/topup/${IDs}_${SubDate_and_ID}_field --iout=$out/prestats/topup/${IDs}_${SubDate_and_ID}_topup_iout

	# Actually correct field distortion
	#applytopup --imain=$inputnifti --datain=$acqp --inindex=1 --topup=$out/prestats/topup/${IDs}_${SubDate_and_ID}_topup --out=$out/prestats/topup/${IDs}_${SubDate_and_ID}_topup_applied --method=jac

	# Average MR signal over all volumes so brain extraction can work on signal representative of whole scan
	##fslmaths $inputnifti -Tmean $out/prestats/eddy/${IDs}_mean_for_init_mask.nii.gz

	# Brain extraction mask for eddy, -m makes binary mask
#	init_mask=$out/prestats/eddy/${IDs}_init_bet.nii.gz

#	bet ${out}/unproc/${IDs}_MultiShell_Merged.nii.gz ${init_mask} -m -f 0.2

	# Create index for eddy to know which acquisition parameters apply to which volumes.(Original usage only correcting A>P, only using one set of acq params.)
#	for ((i=1; i<=119; i+=1)); do indx="$indx 1"; done
#	echo $indx > ${eddy_outdir}/index.txt

	# Run eddy correction. Corrects for Electromagnetic-pulse induced distortions. Most computationally intensive of anything here, has taken >5 hours. More recent eddy correction available in more recent FSL versions	
##	 /share/apps/fsl/5.0.9-eddy-patch/bin/eddy_openmp --imain=${inputnifti} --mask=$out/prestats/eddy/${IDs}_init_bet_mask.nii.gz --index=${eddy_outdir}/index.txt --acqp=$acqp --bvecs=$bvec --bvals=$out/prestats/qa/${IDs}_roundedbval.bval --data_is_shelled --out=$eddy_outdir/${IDs}_eddied.nii.gz --repol
	
	eddy_output=$eddy_outdir/${IDs}_eddied.nii.gz
	
	# Mask eddy output using init mask, make first b0 only for coreg
	fslmaths ${eddy_output} -mas $init_mask ${eddy_outdir}/${IDs}_eddied_initMasked.nii.gz

	fslroi ${eddy_outdir}/${IDs}_eddied_initMasked.nii.gz ${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz 0 1
	 	
	masked_b0=${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz

        
	#NOTE BVECS should be rotated automatically in all post 5.0.9 eddy patches if bvecs read correctly. How to confirm this here https://fsl.fmrib.ox.ac.uk/fsl/fslwiki/eddy/UsersGuide#HelpOnRotBvec

	##############################################
	###           coregistration 		   ###
	##############################################

	# Make mask from fsl's bet from T1

	bet /data/jux/daviska/lkini/3T_Subjects/${IDs}/img/orig/T1/nii/${IDs}_3T_T1.nii.gz ${out}/coreg/${IDs}_T1_betted.nii.gz -m -f .6

	# More stringent one for B0 coreg
	
	bet /data/jux/daviska/lkini/3T_Subjects/${IDs}/img/orig/T1/nii/${IDs}_3T_T1.nii.gz ${out}/coreg/${IDs}_T1_bettedStrin.nii.gz -m -f .75

	# Segment T1 into white matter for coreg

	fast ${out}/coreg/${IDs}_T1_betted.nii.gz
	
	# make white matter only mask from segmented T1 in prep for flirt BBR
	fslmaths ${out}/coreg/${IDs}_T1_betted_seg.nii.gz -thr 3 -uthr 3 $out/coreg/${IDs}_Struct_WM.nii.gz

	# use flirt to calculate diffusion -> structural translation 
	flirt -cost bbr -wmseg $out/coreg/${IDs}_Struct_WM.nii.gz -in ${masked_b0}.nii.gz -ref ${out}/coreg/${IDs}_T1_betted.nii.gz -out $out/coreg/${IDs}_flirt_BBR -dof 6 -omat $out/coreg/${IDs}_MultiShDiff2StructFSL.mat

	# Convert FSL omat to Ras
	c3d_affine_tool -src ${masked_b0} -ref ${out}/coreg/${IDs}_T1_betted.nii.gz $out/coreg/${IDs}_MultiShDiff2StructFSL.mat -fsl2ras -oitk $out/coreg/${IDs}_MultiShDiff2StructRas.mat

	# Use Subject to template warp and affine from grmpy directory after Ras diffusion -> structural space affine to put eddied_bet_2 onto pnc template
	#antsApplyTransforms -e 3 -d 3 -i ${masked_b0} -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/coreg/${bblIDs}_${SubDate_and_ID}_eddied_b0_template_space.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# Take T1 generated mask to sequence (diffusion) space
	antsApplyTransforms -e 3 -d 3 -i ${out}/coreg/${IDs}_T1_betted_mask.nii.gz -r ${masked_b0} -o $out/prestats/eddy/${IDs}_seqSpaceT1Mask.nii.gz -t [$out/coreg/${IDs}_MultiShDiff2StructRas.mat,1] -n NearestNeighbor

	###########################################################
	##           B0-BASED CORRECTION (field distortion)      ##
	###########################################################
	
	# Grab Magnitude B0	
	#cp $general/B0map_Series0012/* /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Magnitude
	#cd /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Magnitude
	#dcm2nii *

	# Extract brain
	#bet *.nii.gz Mag_B0_Betted.nii.gz -f .7

	# Make extraction tigher via erosion, reccomended on fsl webpage
	#fslmaths Mag_B0_Betted.nii.gz -ero Mag_B0_Betted_Ero.nii.gz

	# WE CAN REBUILD HIM... FASTER... STRONGER... TIGHTER...(erode again)
	#fslmaths Mag_B0_Betted_Ero.nii.gz -ero Mag_B0_Betted_Ero.nii.gz
	
	# Grab phase B0
	#cp $general/B0map_Series0013/* /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Phase
	#cd /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Phase
	#dcm2nii *

	# Synthesize into fieldmap for correction
	#fsl_prepare_fieldmap SIEMENS ${out}/unproc/B0_Phase/*.nii.gz ${out}/unproc/B0_Magnitude/Mag_B0_Betted_Ero.nii.gz ${out}/prestats/fieldmap.nii.gz 2.46

	# use flirt to calculate fieldmap -> structural translation 
	#flirt -in /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/unproc/B0_Magnitude/Mag_B0_Betted.nii.gz -ref ${out}/coreg/${IDs}_T1_bettedStrin.nii.gz -out ${out}/prestats/fieldmap_struct.nii.gz -dof 6 -omat $out/coreg/${IDs}_FieldMap2StructFSL.mat

	# Convert FSL omat to Ras
	#c3d_affine_tool -src ${out}/prestats/fieldmap.nii.gz -ref ${out}/coreg/${IDs}_T1_betted.nii.gz $out/coreg/${IDs}_FieldMap2StructFSL.mat -fsl2ras -oitk $out/coreg/${IDs}_FieldMap2StructRas.mat

	# Take Fieldmap to T1 space
	#antsApplyTransforms -e 3 -d 3 -i ${out}/prestats/fieldmap.nii.gz -r ${out}/coreg/${IDs}_T1_bettedStrin.nii.gz -o $out/coreg/${IDs}_StructSpaceFieldMap.nii.gz -t $out/coreg/${IDs}_FieldMap2StructRas.mat -n NearestNeighbor

	# Take Fieldmap from T1 space to sequence (diffusion) space via affine
	#antsApplyTransforms -e 3 -d 3 -i ${out}/coreg/${IDs}_StructSpaceFieldMap.nii.gz -r ${masked_b0} -o $out/coreg/${IDs}_seqSpaceFieldMap.nii.gz -t [$out/coreg/${IDs}_MultiShDiff2StructRas.mat,1] -n NearestNeighbor

	# Fieldmap warp into diffusion space
	
	#fnirt --ref=${masked_b0} --in=$out/coreg/${IDs}_seqSpaceFieldMap.nii.gz 
	#applywarp -i $out/coreg/${IDs}_seqSpaceFieldMap.nii.gz -o $out/coreg/${IDs}_seqSpaceFM_Warped -r ${masked_b0} -w $out/coreg/${IDs}_seqSpaceFieldMap_warpcoef.nii.gz
	# Apply field distortion correction to eddy corrected thing with initial mask

	#fugue -i ${eddy_output} --dwell=0.00069 --loadfmap=$out/coreg/${IDs}_seqSpaceFieldMap.nii.gz -u ${IDs}_fugued.nii.gz

	# Move fugued file because fugue won't accept a destination directory without trying to shame me into believing my output file should exist already 
	
	#mv ${out}/unproc/B0_Phase/${IDs}_fugued.nii.gz ${out}/prestats/${IDs}_fugued.nii.gz

	########################################################
	##   ANTs-based distortion correction (replaced b0)   ##
	########################################################
	
	# Inverse DWI space T1
	fslmaths /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted.nii.gz -mul -1 /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_neg.nii.gz

	minmax="$(fslstats /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted.nii.gz -R)"
	min=$(echo $minmax | cut -d ' ' -f1)
	max=$(echo $minmax | cut -d ' ' -f2)
	range=$(echo "${max} - ${min}" | bc)

	fslmaths /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_neg.nii.gz -add $max /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse.nii.gz

	# Make B0 only from t1 masked eddy
	#fslroi /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/eddy/${IDs}_eddied_t1Masked.nii.gz /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/eddy/${IDs}_eddied_t1Masked_b0.nii.gz 0 1
	B0minmax="$(fslstats ${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz -R)"
	B0min=$(echo $B0minmax | cut -d ' ' -f1)
	B0max=$(echo $B0minmax | cut -d ' ' -f2)
	rangeB0=$(echo "${B0max} - ${B0min}" | bc)
	echo $rangeB0 rangeB0
	echo $range range

	# Scale inverse to B0
	Scale=$(echo "scale=5 ; ${range} / ${rangeB0}" | bc)
	echo $Scale
	fslmaths /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse.nii.gz -mul $Scale /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse_Scaled.nii.gz

	#remask Inversed T1
	fslmaths /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse_Scaled.nii.gz -mas $out/coreg/${IDs}_T1_betted_mask.nii.gz /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse_Scaled_Masked.nii.gz

	# Take T1 to DWI space, to keep DWI resolution
	antsApplyTransforms -e 3 -d 3 -i /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/coreg/${IDs}_T1_betted_Inverse_Scaled_Masked.nii.gz -r ${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz -o $out/coreg/${IDs}_DWISpaceT1.nii.gz -t [$out/coreg/${IDs}_MultiShDiff2StructRas.mat,1] -n NearestNeighbor

	# Affine DWI to T1  (prep for undistorting) (ALREADY RAN AFFINE on T1->DWI
	###antsApplyTransforms -e 3 -i ${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz -r $out/coreg/${IDs}_DWISpaceT1.nii.gz -o $out/prestats/eddy/${IDs}_DWI_T1Affined.nii.gz -t $out/coreg/${IDs}_MultiShDiff2StructRas.mat -n NearestNeighbor 

	# take b0 out
	##fslroi $out/prestats/eddy/${IDs}_T1SpaceDWI_Affined.nii.gz $out/prestats/eddy/${IDs}_T1SpaceDWI_Affined_b0.nii.gz 0 1
	
	# aaaaand undistort
	/data/jux/daviska/apines/ANTs/Scripts/antsRegistrationSyN.sh -d 3 -f $out/coreg/${IDs}_DWISpaceT1.nii.gz -m ${eddy_outdir}/${IDs}_eddied_initMasked_b0.nii.gz -o /data/jux/daviska/apines/3T_Subjects_NODDI/${IDs}/prestats/${IDs}_DWI_T1Warp_B -t br -s 100 -j 1

	antsApplyTransforms -d 3 -e 3 -i $out/prestats/eddy/${IDs}_eddied.nii.gz -o $out/prestats/${IDs}_eddied_undistort_warped.nii.gz -r $out/prestats/${IDs}_DWI_T1Warp_BWarped.nii.gz -t $out/prestats/${IDs}_DWI_T1Warp_B1Warp.nii.gz -t $out/prestats/${IDs}_DWI_T1Warp_B0GenericAffine.mat 

	#remask eddy output using T1 space generated mask

	fslmaths  $out/prestats/${IDs}_eddied_undistort_warped.nii.gz -mas $out/prestats/eddy/${IDs}_seqSpaceT1Mask.nii.gz  $out/prestats/${IDs}_eddied_undistort_warped_t1Masked.nii.gz

	########################################################
	###                AMICO/NODDI			     ###
	########################################################

	# Generate AMICO scheme (edit paths for files like mask and eddy output in generateamicoM script, also this version has a 700 shell, where HCP has 800 shell)
	~/generateAmicoM_AP_KD.pl $IDs

	# Run AMICO
	runAmicoScript=${out}/AMICO/runAMICO.m
	/data/jux/daviska/apines/amicoSYRP/scripts/runAmico.sh ${out}/AMICO/runAMICO.m

	#pushd /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO/
	#matlab -nosplash -nodesktop -r "runAMICO.m; exit()"
	#popd
	
	# Make NODDI Dir
	#NODDIdir=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/AMICO
	
	# Zip and rename native space NODDI outputs to subejct specific
	#gzip $NODDIdir/*.nii
	#mv $NODDIdir/FIT_dir.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz 
	#mv $NODDIdir/FIT_ICVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz 
	#mv $NODDIdir/FIT_ISOVF.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF.nii.gz 
	#mv $NODDIdir/FIT_OD.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz 
	
	########################################################
	##       Native NODDI outputs to template space       ##
	########################################################

	# Translate and Warp amico Outputs to normalized Space (dependent on structural to template translation and warp already being calculated, sequence to structural calculated above)

	# Fit -> Template
	#antsApplyTransforms -e 3 -d 3 -i $NODDIdir/FIT_dir.nii.gz $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_dir.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_FIT_dir_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# ICVF -> Template 
	#antsApplyTransforms -e 3 -d 3 -i $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_FIT_ICVF_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# ISOVF -> Template
	#antsApplyTransforms -e 3 -d 3 -i $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_FIT_ISOVF_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# OD -> Template
	#antsApplyTransforms -e 3 -d 3 -i $NODDIdir/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz -r /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz -o $out/norm/${bblIDs}_${SubDate_and_ID}_FIT_OD_Std.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate1Warp.nii.gz -t /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*SubjectToTemplate0GenericAffine.mat -t $out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat

	# Add Simlinks
	#ln -s /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz $out/norm/
	#ln -s /data/joy/BBL/studies/pnc/template/pnc_template_brain_2mm.nii.gz $out/coreg/
	#ln -s $eddy_outdir/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz $out/coreg
	#ln -s /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_BrainExtractionMask.nii.gz $out/coreg/
	#ln -s /data/joy/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_ExtractedBrain0N4.nii.gz $out/coreg/

	###################################
	###         Cleanup             ###
	###################################

#rm $out/AMICO/*.nii*
#rm $out/AMICO/bvals
#rm $out/AMICO/bvecs

#done

# Pull ROI values from each subject into one csv (example uses JHU 2mm labels, grabs standard space ICVF, outputs into working directory)*

# 3dROIstats -mask JHU-ICBM-labels-2mm-PNC.nii.gz -1DRformat /data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/*/*/norm/*FIT_ICVF_Std.nii.gz >ICVF_all

# *may require some manual cleaning
