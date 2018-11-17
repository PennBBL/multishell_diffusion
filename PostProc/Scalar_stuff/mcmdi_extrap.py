####!/data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python

# Just mcmdi on extrapolated multi-shell diffusion data.
# Fick, Rutger HJ, et al. “MAPL: Tissue microstructure estimation using Laplacian-regularized MAP-MRI and its application to HCP data.” NeuroImage (2016).
# http://nipy.org/dipy/examples_built/reconst_mapmri.html#fick2016a


# Some of these imports may be redundant
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
from IPython.display import Image
import matplotlib.image as mpimg
from dipy.reconst.mapmri import MapmriModel
from dipy.data import get_sphere
from dipy.reconst import mapmri
from dipy.viz import window, actor
from dipy.data import fetch_cfin_multib, read_cfin_dwi, get_sphere
from dipy.core.gradients import gradient_table
from mpl_toolkits.axes_grid1 import make_axes_locatable
import cvxpy as cvxpy
import dmipy
from dmipy.signal_models import cylinder_models, gaussian_models
from dmipy.core import modeling_framework
from dmipy.data import saved_data

# Get input arguments for filenames
bblIDs = sys.argv[1]
subdate_and_ID = sys.argv[2]


# Load in neede data
nii= "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_" + "extrap_map.nii.gz"
mask =  "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_seqSpaceT1Mask.nii.gz"
data, affine = load_nifti(nii)
mask = nib.load(mask).get_data() > 1e-6
mask = mask[...,0]
bval = "/home/apines/roundedbval_extrap.bval"
bvec =  "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_extrap_bvecs.bvec"
bvals, bvecs = read_bvals_bvecs(bval, bvec)
gtab = gradient_table(bvals, bvecs, b0_threshold=10,
                  big_delta=0.04027, small_delta=0.01156)
qvecs = gtab.qvals[:, None] * gtab.bvecs

#### For Multi-compartment Microscopic diffusion imaging - http://nbviewer.jupyter.org/github/AthenaEPI/mipy/blob/master/examples/example_multi_compartment_spherical_mean_technique.ipynb

# DMIPY stuff - used on Multi-Compartment Microscopic Diffusion Imaging


# Set up model
stick = cylinder_models.C1Stick()
zeppelin = gaussian_models.G2Zeppelin()

mcdmi_mod = modeling_framework.MultiCompartmentSphericalMeanModel(
    models=[stick, zeppelin])
mcdmi_mod.parameter_names
mcdmi_mod.set_tortuous_parameter('G2Zeppelin_1_lambda_perp',
    'C1Stick_1_lambda_par','partial_volume_0', 'partial_volume_1')
mcdmi_mod.set_equal_parameter('G2Zeppelin_1_lambda_par', 'C1Stick_1_lambda_par')

# Feed data into model
difolder= "/data/jux/BBL/projects/multishell_diffusion/processedData/multishellPipelineFall2017/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/"

bvalmm = bvals

bvalmcmdi = (bvalmm * 1e6)

scheme = dmipy.data.saved_acquisition_schemes.acquisition_scheme_from_bvalues(bvalmcmdi,bvecs,0.01156,0.040276,TE=0.08280,min_b_shell_distance=300.0,b0_threshold=0.0)

mcdmi_fit = mcdmi_mod.fit(scheme, data, mask=mask)

for i, (names,values) in enumerate(mcdmi_fit.fitted_parameters.items()):
	save_nifti(difolder + str(bblIDs) + "_" + str(subdate_and_ID) + "_extrapolated_" + names, values, affine)


