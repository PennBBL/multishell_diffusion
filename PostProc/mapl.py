####!/data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python
###!/usr/bin/python
###/data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python3
# coding: utf-8

# In[1]:


# Basic run-thru of MAPL processing on one grmpy subject with average QA metrics
# Fick, Rutger HJ, et al. “MAPL: Tissue microstructure estimation using Laplacian-regularized MAP-MRI and its application to HCP data.” NeuroImage (2016).
# http://nipy.org/dipy/examples_built/reconst_mapmri.html#fick2016a


# In[2]:
import sys
import warnings; warnings.simplefilter('ignore')
import matplotlib.pyplot as plt
import nibabel as nib
import numpy as np
from dipy.io.image import load_nifti, save_nifti
from dipy.io import read_bvals_bvecs
from dipy.core.gradients import gradient_table
from tqdm import tqdm
from dipy.reconst.dsi import half_to_full_qspace


# In[3]:

bblIDs = sys.argv[1]
subdate_and_ID = sys.argv[2]

nii= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_eddied_sls.nii.gz"

bval = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/qa/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_roundedbval.bval"

bvec =  "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_eddied_sls.eddy_rotated_bvecs"

mask =  "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_seqSpaceT1Mask.nii.gz"

data, affine = load_nifti(nii)
mask = nib.load(mask).get_data() > 1e-6
mask = mask[...,0]
bvals, bvecs = read_bvals_bvecs(bval, bvec)
gtab = gradient_table(bvals, bvecs, b0_threshold=10,
                  big_delta=0.04027, small_delta=0.01156)
qvecs = gtab.qvals[:, None] * gtab.bvecs


import matplotlib.image as mpimg
from dipy.reconst.mapmri import MapmriModel
from dipy.data import get_sphere
sphere = get_sphere('symmetric724')
radial_order=8

map_model = MapmriModel(gtab, radial_order=radial_order,
                       laplacian_regularization=True,
                       laplacian_weighting="GCV", anisotropic_scaling=False)
mapfit = map_model.fit(data, mask=mask)
coef_name = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_coefs.nii.gz"
save_nifti(coef_name,mapfit._mapmri_coef,affine)

mus_name = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_mus.nii.gz"
save_nifti(mus_name,mapfit.mu,affine)

rtop_laplacian = np.array(mapfit.rtop()[:, :, :], dtype=float)
rtap_laplacian = np.array(mapfit.rtap()[:, :, :], dtype=float)
rtpp_laplacian = np.array(mapfit.rtpp()[:, :, :], dtype=float)


rtop_name = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtop.nii.gz"
save_nifti(rtop_name,rtop_laplacian,affine)

rtap_name = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtap.nii.gz"
save_nifti(rtap_name,rtap_laplacian,affine)

rtpp_name = "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtpp.nii.gz"
save_nifti(rtpp_name,rtpp_laplacian,affine)


