#!/bin/bash
##example to edit 


subjDataName="/data/joy/BBL/projects/voxelwiseAnalysisWrappers/voxelBlowOut/data/n2416_pnc_Demographics_ROIGAMM.rds" #change to your RDS for grmpy-- has demo + QA data in it
#OutDirRoot="/data/joy/BBL/projects/multishell_diffusion/GroupLevelAnalyses"  #change to your projects directory-- would create a "group level analyses" folder below project leevel
#inputPath="/data/joy/BBL/studies/pnc/n2416_dataFreeze/neuroimaging/t1struct/n2416_jlfAntsCTIntersectionCt_20170331.csv"  #path to CSV of your ODI or ND values
inclusionName="noddiExclude"  #change to exclude code-- needs to be in RDS above, binary values.  1==exclude
subjID="bblid,scanid" # in the brain .csv file -- columns not to run model on
covsFormula="~s(age,k=4,method="REML")+ sex + diffusionQAVal + totalARI"
	#sex should be ordered factor; diffusionQAVal should tSNR that we use for inclusion/exclusion cutoff.
pAdjustMethod="fdr"
ncores=5
residualMap=FALSE

Rscript /data/joy/BBL/applications/groupAnalysis/gamROI.R -c $subjDataName -o $OutDirRoot -p $inputPath -i $inclusionName -u $subjID -f $covsFormula -a $pAdjustMethod -r $residualMap -n 5 

