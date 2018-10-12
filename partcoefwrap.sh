#!/bin/bash
ci=csvread('/data/jux/BBL/projects/pncBaumDti/Schaefer200_Yeo7_affil.txt')   
for i in ~/torun.txt

matlab -nodisplay;W=csvread('90683_20160508x10142_ICVF_matrixts.csv',1,0);cd '/data/jux/BBL/projects/multishell_diffusion/multishell_diffusionScripts/';participation_coef(W,ci);

