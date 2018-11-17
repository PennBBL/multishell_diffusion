#!/usr/bin/perl -w

use strict;

use File::Spec;


my $usage = qq{

  $0 <subject> <timepoint>  

  Copies data and generates a .m file for submission to SGE with runAmico.sh

};

if ($#ARGV < 0) {
  print $usage;
  exit 1;
}


my ($subj, $tp) = @ARGV;

my $appsDir = "/data/joy/BBL/projects/multishell_diffusion/multishell_diffusionScripts/amicoSYRP/bin";

my $inputDir = "/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${subj}/${tp}";

my $bvals = "${inputDir}/prestats/qa/${subj}_${tp}_roundedbval.bval";

my $bvecs = "${inputDir}/prestats/eddy/${subj}_${tp}_eddied.eddy_rotated_bvecs";

my $data = "${inputDir}/prestats/eddy/${subj}_${tp}_eddied.nii.gz";

my $mask = "${inputDir}/prestats/eddy/${subj}_${tp}_seqSpaceT1Mask.nii.gz";

my $amicoDataDir = "/data/joy/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/${subj}/${tp}/AMICO";

system("mkdir -p $amicoDataDir");

system("cp $bvals ${amicoDataDir}/bvals");
system("cp $bvecs ${amicoDataDir}/bvecs");
system("cp $data ${amicoDataDir}/dwi.nii.gz");
system("gunzip ${amicoDataDir}/dwi.nii.gz");
system("cp $mask ${amicoDataDir}/brainMask.nii.gz");
system("gunzip ${amicoDataDir}/brainMask.nii.gz");

my $script = qq{ 

clearvars, clearvars -global, clc

addpath('${appsDir}/AMICO/matlab')

% Setup AMICO
AMICO_Setup

AMICO_SetSubject( 'multishellPipelineFall2017', '${subj}/${tp}' )

CONFIG.dwiFilename    = fullfile( CONFIG.DATA_path, 'AMICO/dwi.nii' );
CONFIG.maskFilename   = fullfile( CONFIG.DATA_path, 'AMICO/brainMask.nii' );
CONFIG.schemeFilename = fullfile( CONFIG.DATA_path, 'AMICO/amicoScheme.scheme' );

AMICO_fsl2scheme(fullfile( CONFIG.DATA_path, 'AMICO/bvals' ), fullfile( CONFIG.DATA_path, 'AMICO/bvecs' ), fullfile( CONFIG.DATA_path, 'AMICO/amicoScheme.scheme') , [0, 300, 800, 2000])

% Load the dataset in memory
AMICO_LoadData

% Setup AMICO to use the 'NODDI' model
AMICO_SetModel( 'NODDI' );

% Generate the kernels corresponding to the protocol
AMICO_GenerateKernels( true );

% Resample the kernels to match the specific subject's scheme
AMICO_ResampleKernels();

AMICO_Fit()


};

open(my $fh, ">", "${amicoDataDir}/runAMICO.m");

print $fh $script;

close $fh; 

exit
