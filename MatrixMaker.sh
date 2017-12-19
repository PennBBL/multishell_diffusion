#!/bin/bash
cdir=/data/joy/BBL/applications/camino/bin
ddir=/share/apps/dsistudio/2016-01-25/bin
general=/data/joy/BBL/studies/grmpy/rawData/*/*
export CAMINO_HEAP_SIZE=10000
for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
in=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
seed_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_Schaef_WM_intersect.nii.gz
model_fit_path=$out/tractography/${bblIDs}_${SubDate_and_ID}_WdtModelFit.Bdouble
waypoint_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceWM.nii.gz
exclusion_path=$out/coreg/${bblIDs}_${SubDate_and_ID}_seqspaceCSF.nii.gz
dsource=$out/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz
tractography_output=$out/tractography/${bblIDs}_${SubDate_and_ID}_Tract.Bdouble

#copy scalars to coreg folder so conmat can run
cp $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz $out/coreg/
cp $out/AMICO/NODDI/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz $out/coreg/
cp $out/dsi/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.fa0.nii.gz $out/coreg
# Mean ICVF matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}_FIT_ICVF.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_ICVF_matrix

# Mean ODI matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}_FIT_OD.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_ODI_matrix

#shady step to make FA and Schaef_WM_Interesect equivalent
fslcpgeom $seed_path $out/coreg/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.fa0.nii.gz

# Mean FA matrix
$cdir/conmat -inputfile "${tractography_output}" -targetfile "${seed_path}" -scalarfile $out/coreg/${bblIDs}_${SubDate_and_ID}t1_maskedEddied.src.gz.fy.dti.fib.gz.fa0.nii.gz -tractstat mean -outputroot $out/tractography/${bblIDs}_${SubDate_and_ID}_FA_matrix

done
