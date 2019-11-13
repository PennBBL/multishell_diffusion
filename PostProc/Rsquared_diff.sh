#!/bin/bash

# takes residuals from two different voxelwise outputs, and makes R^2 difference map

# intended for multishell comparisons manuscript to look at the R^2 difference that age terms (linear, quadratic, and cubic) make in linear models

parentdir=$1
mask=${parentdir}/mask.nii.gz

### |||| No age R^2 |||| ###

# mask fourd input
fslmaths ${parentdir}/fourd.nii.gz -mas ${mask} ${parentdir}/fourd_masked
# get mean of each voxel
fslmaths ${parentdir}/fourd_masked.nii.gz -Tmean ${parentdir}/fourd_masked_mean
# get orig values minus mean
fslmaths ${parentdir}/fourd.nii.gz -sub ${parentdir}/fourd_masked_mean.nii.gz ${parentdir}/fourd_minus_mean
# square orig-mean values
fslmaths ${parentdir}/fourd_minus_mean.nii.gz -sqr ${parentdir}/fourd_minus_mean_sqr
# average squared deviation from mean (average total sum of squared)
fslmaths ${parentdir}/fourd_minus_mean_sqr.nii.gz -Tmean ${parentdir}/avg_t_sumosquared

# get residuals squared
fslmaths ${parentdir}/n120lm_Cov_sex_meanRELrms/lm_residualMap.nii.gz -sqr ${parentdir}/resid_sqr
# get mean of residuals squared for each voxel (average residuals squared)
fslmaths ${parentdir}/resid_sqr.nii.gz -Tmean ${parentdir}/resid_sqr_mean

# residuals squared / total sum of squared
fslmaths ${parentdir}/resid_sqr_mean.nii.gz -div ${parentdir}/avg_t_sumosquared.nii.gz ${parentdir}/resid_over_sumsquar

# 1 - answer is R^2 for this model, mask can conveniently serve as value of 1 in space
fslmaths ${mask} -sub ${parentdir}/resid_over_sumsquar.nii.gz ${parentdir}/Rsquared_noage

### |||| Age included R^2 |||| ###

# get residuals squared
fslmaths ${parentdir}/n120lm_Cov_age_Iage^2_Iage^3_sex_meanRELrms/lm_residualMap.nii.gz -sqr ${parentdir}/resid_sqr_age
# get mean of residuals squared for each voxel (average residuals squared)
fslmaths ${parentdir}/resid_sqr_age.nii.gz -Tmean ${parentdir}/resid_sqr_age_mean

# residuals squared / total sum of squared
fslmaths ${parentdir}/resid_sqr_age_mean.nii.gz -div ${parentdir}/avg_t_sumosquared.nii.gz ${parentdir}/resid_age_over_sumsquar

# 1 - answer is R^2 for this model, mask can conveniently serve as value of 1 in space
fslmaths ${mask} -sub ${parentdir}/resid_age_over_sumsquar.nii.gz ${parentdir}/Rsquared_age

### |||| Difference |||| ###
fslmaths ${parentdir}/Rsquared_age.nii.gz -sub ${parentdir}/Rsquared_noage.nii.gz ${parentdir}/Rsquared_dif.nii.gz

### cleanup some niftis ###
rm ${parentdir}/fourd_masked.nii.gz
rm ${parentdir}/fourd_minus_mean.nii.gz
rm ${parentdir}/fourd_minus_mean_sqr.nii.gz
rm ${parentdir}/resid_sqr.nii.gz
rm ${parentdir}/resid_sqr_age.nii.gz
