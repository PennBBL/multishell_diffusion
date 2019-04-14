####!/data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python
# coding: utf-8

# This script right here will use the mapmri software to fit your multi-shell data. It will also calculate return to origin, axis, and plane probabilities. It will also fit the multi-compartment microscopic diffusion model, and extrapolate additional "shells" of data from the fit, if you so desire, or if you forget to comment it out. 

# Shoutout to Fick, Rutger HJ, et al. “MAPL: Tissue microstructure estimation using Laplacian-regularized MAP-MRI and its application to HCP data.” NeuroImage (2016).
# http://nipy.org/dipy/examples_built/reconst_mapmri.html#fick2016a

# Multi-compartment microscopic diffusion: 
#https://www.sciencedirect.com/science/article/pii/S1053811916302063
#http://nbviewer.jupyter.org/github/AthenaEPI/mipy/blob/master/examples/example_multi_compartment_spherical_mean_technique.ipynb

# In case you are new to python, you'll need to install these packages before using this script.
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


# Load in data

bblIDs = sys.argv[1]
subdate_and_ID = sys.argv[2]

nii= "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_eddied_sls.nii.gz"

bval = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/qa/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_roundedbval.bval"

bvec =  "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_eddied_sls.eddy_rotated_bvecs"

mask =  "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_seqSpaceT1Mask.nii.gz"

data, affine = load_nifti(nii)
mask = nib.load(mask).get_data() > 1e-6
mask = mask[...,0]
bvals, bvecs = read_bvals_bvecs(bval, bvec)
gtab = gradient_table(bvals, bvecs, b0_threshold=10,
                  big_delta=0.04027, small_delta=0.01156)
qvecs = gtab.qvals[:, None] * gtab.bvecs

# Reconstruct mapmri. Set radial order lower for faster computing

import matplotlib.image as mpimg
from dipy.reconst.mapmri import MapmriModel
from dipy.data import get_sphere
sphere = get_sphere('symmetric724')
radial_order=8

# Currently includes laplacian regularization, but not anisotropic scaling.
map_model = MapmriModel(gtab, radial_order=radial_order,
                       laplacian_regularization=True,
                       laplacian_weighting="GCV", anisotropic_scaling=False)

# The workhorse line right down yonder
mapfit = map_model.fit(data, mask=mask)

# save outputs
coef_name = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_coefs.nii.gz"
save_nifti(coef_name,mapfit._mapmri_coef,affine)

mus_name = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_mus.nii.gz"
save_nifti(mus_name,mapfit.mu,affine)

# get your nice, biologically interpretable scalars and save em
rtop_laplacian = np.array(mapfit.rtop()[:, :, :], dtype=float)
rtap_laplacian = np.array(mapfit.rtap()[:, :, :], dtype=float)
rtpp_laplacian = np.array(mapfit.rtpp()[:, :, :], dtype=float)


rtop_name = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtop.nii.gz"
save_nifti(rtop_name,rtop_laplacian,affine)

rtap_name = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtap.nii.gz"
save_nifti(rtap_name,rtap_laplacian,affine)

rtpp_name = "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtpp.nii.gz"
save_nifti(rtpp_name,rtpp_laplacian,affine)

from dipy.reconst import mapmri
from dipy.viz import window, actor
from dipy.data import fetch_cfin_multib, read_cfin_dwi, get_sphere
from dipy.core.gradients import gradient_table
import matplotlib.pyplot as plt
import numpy as np
from mpl_toolkits.axes_grid1 import make_axes_locatable
import cvxpy as cvxpy


# In[8]:

#### For Multi-compartment Microscopic diffusion imaging - http://nbviewer.jupyter.org/github/AthenaEPI/mipy/blob/master/examples/example_multi_compartment_spherical_mean_technique.ipynb


# Multi-Compartment Microscopic Diffusion Imaging
import dmipy
from dmipy.signal_models import cylinder_models, gaussian_models
stick = cylinder_models.C1Stick()
zeppelin = gaussian_models.G2Zeppelin()

from dmipy.core import modeling_framework
mcdmi_mod = modeling_framework.MultiCompartmentSphericalMeanModel(
    models=[stick, zeppelin])
mcdmi_mod.parameter_names
mcdmi_mod.set_tortuous_parameter('G2Zeppelin_1_lambda_perp',
    'C1Stick_1_lambda_par','partial_volume_0', 'partial_volume_1')
mcdmi_mod.set_equal_parameter('G2Zeppelin_1_lambda_par', 'C1Stick_1_lambda_par')


difolder= "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/"

# Slightly different units needed for these bvals for this fit

bvalmm = bvals
bvalmcmdi = (bvalmm * 1e6)

from dmipy.data import saved_data

scheme = dmipy.data.saved_acquisition_schemes.acquisition_scheme_from_bvalues(bvalmcmdi,bvecs,0.01156,0.040276,TE=0.08280,min_b_shell_distance=300.0,b0_threshold=0.0)

mcdmi_fit = mcdmi_mod.fit(scheme, data, mask=mask)


# Save output

for i, (names,values) in enumerate(mcdmi_fit.fitted_parameters.items()):
	save_nifti(difolder + str(bblIDs) + "_" + str(subdate_and_ID) + "_" + names, values, affine)



# Extrapolate shell(s). Currently set to extrapolate a b3000 shell.

# Requires you to create bval and bvec-extrapolated beforehand. As long as you format them in correctly, you can really extrapolate any missing b values or b vectors from here. Check out https://hal.inria.fr/hal-01291929/document, "MAPL: Tissue Microstructure Estimation Using Laplacian-Regularized MAP-MRI and its Application to HCP Data" for an example of this application

bvale = "/home/apines/roundedbval_extrap.bval"

bvece =  "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_extrap_bvecs.bvec"

bvalse, bvecse = read_bvals_bvecs(bvale, bvece)
gtab = gradient_table(bvalse, bvecse, b0_threshold=10,
                  big_delta=0.04027, small_delta=0.01156)

extrap_map = mapfit.predict(gtab)

save_nifti(difolder + str(bblIDs) + "_" + str(subdate_and_ID) + "_" + "extrap_map", extrap_map, affine)


