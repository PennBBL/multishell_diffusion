#!/bin/bash

# Generate wdt fit in camino for diffusion data, run deterministic tractography, generate scalar-weighted connectivity matrices using Fractional Anisotropy, Intracellular volume fraction, orientation dispersion index, and return-to-origin probability.

# Note many parameters throughout are sequence-specific. Obviously file paths aren't generalizeable.

bblIDs=$1
SubDate_and_ID=$2

out=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}
general=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/raw/$bblIDs/$SubDate_and_ID
cdir=/data/jux/BBL/applications-from-joy/camino/bin
in=/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/${bblIDs}/${SubDate_and_ID}

mkdir $out/tractography

fslmaths /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/*_BrainSegmentation.nii.gz -thr 1 -uthr 1 $out/coreg/${bblIDs}_${SubDate_and_ID}_CSF.nii.gz

#csf to seq space
antsApplyTransforms -e 3 -d 3 -i $out/coreg/${bblIDs}_${SubDate_and_ID}_CSF.nii.gz -r /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz -o $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceCSF.nii.gz -t [/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat,1] -n MultiLabel

#wm to seq space
antsApplyTransforms -e 3 -d 3 -i $out/coreg/${bblIDs}_${SubDate_and_ID}_Struct_WM.nii.gz -r /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz -o $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM.nii.gz -t [/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat,1] -n MultiLabel

#dilate seqspace wm
ImageMath 3 $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM_dil.nii.gz GD $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM.nii.gz 1

#schaefer to seqspace

antsApplyTransforms -e 0 -d 3 -i /data/joy/BBL/tutorials/exampleData/AMICO_NODDI/templates/SchaeferPNC_200.nii.gz -r /data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_topupMasked_b0.nii.gz -o $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceSchaef.nii.gz -n MultiLabel -t [$out/coreg/${bblIDs}_${SubDate_and_ID}_MultiShDiff2StructRas.mat, 1] -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject1GenericAffine.mat -t /data/jux/BBL/studies/grmpy/processedData/structural/struct_pipeline_20170716/$bblIDs/$SubDate_and_ID/antsCT/${bblIDs}_${SubDate_and_ID}_TemplateToSubject0Warp.nii.gz

#get convergence of schaefer and dilated wm
fslmaths $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceSchaef.nii.gz -mas $out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM_dil.nii.gz $out/coreg/${bblIDs}_${SubDate_and_ID}_Schaef_WM_intersect.nii.gz

#fitTensorsinCamino - heap size prevents crashing
export CAMINO_HEAP_SIZE=10000

$cdir/fsl2scheme -bvecfile $in/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.eddy_rotated_bvecs -bvalfile $in/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval > $out/tractography/${bblIDs}_${SubDate_and_ID}.scheme

$cdir/image2voxel -4dimage $in/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied_sls.nii.gz -outputfile $out/tractography/${bblIDs}_${SubDate_and_ID}_i2v.Bfloat

#wdt - weighted linear fit (Jones & Basser, 2004)
$cdir/wdtfit $out/tractography/${bblIDs}_${SubDate_and_ID}_i2v.Bfloat $out/tractography/${bblIDs}_${SubDate_and_ID}.scheme -bgmask $in/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz -outputfile $out/tractography/${bblIDs}_${SubDate_and_ID}_WdtModelFit.Bdouble

seed_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_Schaef_WM_intersect.nii.gz
model_fit_path=$out/tractography/${bblIDs}_${SubDate_and_ID}_WdtModelFit.Bdouble
waypoint_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM.nii.gz
exclusion_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceCSF.nii.gz
tractography_output=$out/tractography/${bblIDs}_${SubDate_and_ID}_Tract.Bdouble

#Camino tractography
$cdir/track -inputmodel dt -seedfile "${seed_path}" -inputfile "${model_fit_path}" -tracker euler -interpolator linear -iterations 20 -curvethresh 60 | $cdir/procstreamlines -waypointfile "${waypoint_path}" -exclusionfile "${exclusion_path}" -truncateinexclusion -endpointfile "${seed_path}" -outputfile "${tractography_output}"

################################################
### Generate connectivity matrices in Camino ###
################################################

# Generate FA from camino
cat $out/tractography/${bblIDs}_${SubDate_and_ID}_WdtModelFit.Bdouble | $cdir/fa | $cdir/voxel2image -outputroot $out/coreg/${bblIDs}_${SubDate_and_ID}_Camino_FA -header $seed_path -gzip

##copy scalars to coreg folder so conmat can run
cp $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz $out/coreg/
cp $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz $out/coreg/
cp $out/prestats/eddy/${bblIDs}_${SubDate_and_ID}_rtop.nii.gz $out/coreg/

# Mean ICVF matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_ICVF_matrix

# Mean FA matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}_Camino_FA.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_FA_matrix

# Mean RTOP matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}_rtop.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_rtop_matrix

