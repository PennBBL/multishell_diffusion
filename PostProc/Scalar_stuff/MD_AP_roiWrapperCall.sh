#!/bin/bash

# run GAMs on ROIs of interest

subjDataName="/data/joy/BBL/projects/multishell_diffusion/GroupLevelAnalyses/rdsFiles/demo_dti_qa_inchead.rds" #change to your RDS for grmpy-- has demo + QA data in it
OutDirRoot="/data/joy/BBL/projects/multishell_diffusion/GroupLevelAnalyses"  #change to your projects directory-- would create a "group level analyses" folder below project leevel
inputPath="/data/joy/BBL/projects/multishell_diffusion/GroupLevelAnalyses/noddiValues/OD_all.csv"  #path to CSV of your ODI or ND values
inclusionName="DTI_qa_exclude"  #change to exclude code-- needs to be in RDS above, binary values.  1==exclude
subjID="bblid" # in the brain .csv file -- columns not to run model on
covsFormula="~s(ageatscan,k=4,method='REML') + sex + bShell_zAvg + ari_total"
	#sex should be ordered factor; diffusionQAVal should tSNR that we use for inclusion/exclusion cutoff.
pAdjustMethod="fdr"
ncores=5
residualMap=FALSE

Rscript /data/joy/BBL/applications/groupAnalysis/gamROI.R -c $subjDataName -o $OutDirRoot -p $inputPath -i $inclusionName -u $subjID -f "~s(ageatscan,k=4,method='REML') + sex + bShell_zAvg + ari_total" -a fdr -r FALSE -n 5
