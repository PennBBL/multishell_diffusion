This repository is divided into two sets of scripts. Preprocessing takes raw diffusion data through preprocessing and various diffusion model fits. Postprocessing includes comparative analyses aimed at evaluating the relative utility of 14 different diffusion metrics for developmental neuroimaging. Further detail below.

#Preprocessing:
###Multishell_Preproc
Raw DWI -> Quality assurance, motion correction, phase-encoding distortion correction, eddy current correction, coregistration to structurals, template, NODDI scalars via AMICO framework
###QAonly
Runs QA independent of preproc pipeline
###QA_extract
Combines subject-level QA into one csv
###bval_rounder
rounds b-value files to multiple of provided integers (for Siemens scanners)
###generateAmicoM_AP
AMICO (Daducci et al., 2015) framework adapted for current dataset/file structure
###index
value of 1 x number of TRs for eddy input
###qa*
series of quality assurance scripts from https://www.med.upenn.edu/cmroi/qascripts.html, requires fsl and afni
### runAmico 
just runs AMICO(Matlab) on an SGE
###slsspec_gen
generates file with basic scan sequence info
wrap_MultiShell_PreProc
For parallel job submission to SGE

#Postprocessing:
###Rsquared_diff
generates r^2 difference maps from voxelwise (CRAN.R-project.org/package=voxel) outputs
###SQcombine
subject-level squareformed (vectorized) tractographyt values into one csv
###ToStandardSpace.sh
Brings subject scalars to standard space, needed for voxelwise analyses
###correlate_scalars
correlates scalars maps within subjects within a white matter mask, obtains a mean correlation for each pair of scalars for each subject
###correlate_scalars_ss
single-shell iteration
###determTract
deterministic tractography utilized
###edge_gams
run generalized additive models on each edge (possible streamline b/w two ROIs) for age effects
###edge_gams_qa 
run generalized additive models on each edge (possible streamline b/w two ROIs) for image quality effects
###mapl
fits mapl model (Fick et al., 2016) to data
###mapl_extrap
fits mapl model with bvalue extrapolation
###multishell_analyses
comprehensive r markdown of analyses ran and figures created for Developmental Cognitive Neuroscience Manuscript
###squareform_new
vectorizes structural connectivity matrices
###wm_mask_stats
uses AFNI to get mean white matter values for each diffusion metric of interest
###wrap_MultiShell_mapl
wrapper for parallel job submission of MAPL fits
###wrap_MultiShell_std_space
wrapper for parallel job submission of standard space affines + warps
###wrap_cors
wrapper for parallel job submission of scalar spatial correlations
###wrap_determTract
wrapper for parallel job submission of deterministic tractography

