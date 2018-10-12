#!/bin/bash
cdir=/data/joy/BBL/applications/camino/bin
in=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/104235/20170623x10585
general=/data/joy/BBL/studies/grmpy/rawData/104235/*
for i in $general;do 
	bblIDs=$(echo ${i}|cut -d'/' -f8 |sed s@'/'@' '@g);
	SubDate_and_ID=$(echo ${i}|cut -d'/' -f9|sed s@'/'@' '@g|sed s@'x'@'x'@g)
	Date=$(echo ${SubDate_and_ID}|cut -d',' -f1)
	ID=$(echo ${SubDate_and_ID}|cut -d',' -f2)

out=/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${bblIDs}/${SubDate_and_ID}
mkdir $out/tractography

$cdir/fsl2scheme -bvecfile $in/prestats/eddy/104235_20170623x10585_eddied.eddy_rotated_bvecs -bvalfile $in/prestats/qa/${bblIDs}_${SubDate_and_ID}_roundedbval.bval > $out/tractography/${bblIDs}_${SubDate_and_ID}.scheme

$cdir/image2voxel -4dimage $in/prestats/eddy/${bblIDs}_${SubDate_and_ID}_eddied.nii.gz -outputfile $out/tractography/${bblIDs}_${SubDate_and_ID}_i2v.Bfloat

$cdir/modelfit -inputfile $out/tractography/${bblIDs}_${SubDate_and_ID}_i2v.Bfloat -schemefile $out/tractography/${bblIDs}_${SubDate_and_ID}.scheme -model ldt -bgmask $in/prestats/eddy/${bblIDs}_${SubDate_and_ID}_seqSpaceT1Mask.nii.gz -outputfile $out/tractography/${bblIDs}_${SubDate_and_ID}_modelFit.Bdouble

done

