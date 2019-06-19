###/data/jux/BBL/projects/multishell_diffusion/envs/mapl/bin/python3

#### For correlating diffusions scalars voxel by voxel, and obtaining average for each subject. Requires the software listed in the requirements section below. #####

# load requirements
import sys
import nibabel as nib
import numpy as np
from scipy.stats.stats import spearmanr
import nilearn
from nilearn.masking import apply_mask

# use args to get scalars of interest

bblIDs = sys.argv[1]
subdate_and_ID = sys.argv[2]

# Load all scalar maps (native space)

ISO="/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/AMICO/NODDI/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_FIT_ISOVF.nii.gz"

FA= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_msFA.nii.gz"

ICVF= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/AMICO/NODDI/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_FIT_ICVF.nii.gz"

RTOP= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtop.nii.gz"

mask =  "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/coreg/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_seqspaceWM.nii.gz"

AD=  "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_msAD.nii.gz"

MD=  "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_msMD.nii.gz"

ODI= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/AMICO/NODDI/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_FIT_OD.nii.gz"

RD= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_msRD.nii.gz"

RTAP= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtap.nii.gz"

RTPP= "/data/joy/BBL/tutorials/exampleData/AMICO_NODDI/Processed_Data/" + str(bblIDs) + "/" + str(subdate_and_ID) + "/prestats/eddy/" + str(bblIDs) + "_" + str(subdate_and_ID) + "_rtpp.nii.gz"

##### make mask into boolean mask, use ravel to flatten
mask_ar=np.array(np.ravel(nib.load(mask).get_data()),dtype=bool)

# Get an array of image intensities, use same mask, all in equivalent canonical orientation
# "m" means "masked"

fa_img=nib.load(FA)
fa_can=nib.as_closest_canonical(fa_img)
FA_ar=np.ravel(nib.load(FA).get_data())
FA_ar=np.ravel(fa_can.get_data())
FAm=FA_ar[mask_ar]

icvf_img=nib.load(ICVF)
icvf_can=nib.as_closest_canonical(icvf_img)
ICVF_ar=np.ravel(nib.load(ICVF).get_data())
ICVF_ar=np.ravel(icvf_can.get_data())
ICVFm=ICVF_ar[mask_ar]

rtop_img=nib.load(RTOP)
rtop_can=nib.as_closest_canonical(rtop_img)
RTOP_ar=np.ravel(nib.load(RTOP).get_data())
RTOP_ar=np.ravel(rtop_can.get_data())
RTOPm=RTOP_ar[mask_ar]

AD_img=nib.load(AD) 
AD_can=nib.as_closest_canonical(AD_img) 
AD_ar=np.ravel(nib.load(AD).get_data()) 
AD_ar=np.ravel(AD_can.get_data()) 
ADm=AD_ar[mask_ar] 

RD_img=nib.load(RD) 
RD_can=nib.as_closest_canonical(RD_img) 
RD_ar=np.ravel(nib.load(RD).get_data()) 
RD_ar=np.ravel(RD_can.get_data()) 
RDm=RD_ar[mask_ar] 

MD_img=nib.load(MD) 
MD_can=nib.as_closest_canonical(MD_img) 
MD_ar=np.ravel(nib.load(MD).get_data()) 
MD_ar=np.ravel(MD_can.get_data()) 
MDm=MD_ar[mask_ar] 

ODI_img=nib.load(ODI) 
ODI_can=nib.as_closest_canonical(ODI_img) 
ODI_ar=np.ravel(nib.load(ODI).get_data()) 
ODI_ar=np.ravel(ODI_can.get_data()) 
ODIm=ODI_ar[mask_ar] 

RTAP_img=nib.load(RTAP) 
RTAP_can=nib.as_closest_canonical(RTAP_img) 
RTAP_ar=np.ravel(nib.load(RTAP).get_data()) 
RTAP_ar=np.ravel(RTAP_can.get_data()) 
RTAPm=RTAP_ar[mask_ar] 

RTPP_img=nib.load(RTPP) 
RTPP_can=nib.as_closest_canonical(RTPP_img) 
RTPP_ar=np.ravel(nib.load(RTPP).get_data()) 
RTPP_ar=np.ravel(RTPP_can.get_data()) 
RTPPm=RTPP_ar[mask_ar] 

ISO_img=nib.load(ISO) 
ISO_can=nib.as_closest_canonical(ISO_img) 
ISO_ar=np.ravel(nib.load(ISO).get_data()) 
ISO_ar=np.ravel(ISO_can.get_data()) 
ISOm=ISO_ar[mask_ar] 

# Calculate array correlations

ISOxFA=spearmanr(ISOm,FAm,nan_policy='omit')
ISOxMD=spearmanr(ISOm,MDm,nan_policy='omit')
ISOxAD=spearmanr(ISOm,ADm,nan_policy='omit')
ISOxRD=spearmanr(ISOm,RDm,nan_policy='omit')
ISOxICVF=spearmanr(ISOm,ICVFm,nan_policy='omit')
ISOxODI=spearmanr(ISOm,ODIm,nan_policy='omit')
ISOxRTOP=spearmanr(ISOm,RTOPm,nan_policy='omit')
ISOxRTPP=spearmanr(ISOm,RTPPm,nan_policy='omit')
ISOxRTAP=spearmanr(ISOm,RTAPm,nan_policy='omit')
FAxICVF=spearmanr(FAm,ICVFm,nan_policy='omit')
FAxRTOP=spearmanr(FAm,RTOPm,nan_policy='omit')
FAxAD=spearmanr(FAm,ADm,nan_policy='omit')
FAxMD=spearmanr(FAm,MDm,nan_policy='omit')
FAxODI=spearmanr(FAm,ODIm,nan_policy='omit')
FAxRD=spearmanr(FAm,RDm,nan_policy='omit')
FAxRTAP=spearmanr(FAm,RTAPm,nan_policy='omit')
FAxRTPP=spearmanr(FAm,RTPPm,nan_policy='omit')
ICVFxRTOP=spearmanr(ICVFm,RTOPm,nan_policy='omit')
ICVFxAD=spearmanr(ICVFm,ADm,nan_policy='omit')
ICVFxMD=spearmanr(ICVFm,MDm,nan_policy='omit')
ICVFxODI=spearmanr(ICVFm,ODIm,nan_policy='omit')
ICVFxRD=spearmanr(ICVFm,RDm,nan_policy='omit')
ICVFxRTAP=spearmanr(ICVFm,RTAPm,nan_policy='omit')
ICVFxRTPP=spearmanr(ICVFm,RTPPm,nan_policy='omit')
RTOPxAD=spearmanr(RTOPm,ADm,nan_policy='omit')
RTOPxMD=spearmanr(RTOPm,MDm,nan_policy='omit')
RTOPxODI=spearmanr(RTOPm,ODIm,nan_policy='omit')
RTOPxRD=spearmanr(RTOPm,RDm,nan_policy='omit')
RTOPxRTAP=spearmanr(RTOPm,RTAPm,nan_policy='omit')
RTOPxRTPP=spearmanr(RTOPm,RTPPm,nan_policy='omit')
ADxMD=spearmanr(ADm,MDm,nan_policy='omit')
ADxODI=spearmanr(ADm,ODIm,nan_policy='omit')
ADxRD=spearmanr(ADm,RDm,nan_policy='omit')
ADxRTAP=spearmanr(ADm,RTAPm,nan_policy='omit')
ADxRTPP=spearmanr(ADm,RTPPm,nan_policy='omit')
MDxODI=spearmanr(MDm,ODIm,nan_policy='omit')
MDxRD=spearmanr(MDm,RDm,nan_policy='omit')
MDxRTAP=spearmanr(MDm,RTAPm,nan_policy='omit')
MDxRTPP=spearmanr(MDm,RTPPm,nan_policy='omit')
ODIxRD=spearmanr(ODIm,RDm,nan_policy='omit')
ODIxRTAP=spearmanr(ODIm,RTAPm,nan_policy='omit')
ODIxRTPP=spearmanr(ODIm,RTPPm,nan_policy='omit')
RDxRTAP=spearmanr(RDm,RTAPm,nan_policy='omit')
RDxRTPP=spearmanr(RDm,RTPPm,nan_policy='omit')
RTAPxRTPP=spearmanr(RTOPm,RTPPm,nan_policy='omit')

print(bblIDs)

myCsvRow= str(bblIDs) + "," + str(ISOxFA[0]) + "," + str(ISOxMD[0]) + "," + str(ISOxAD[0]) + "," + str(ISOxRD[0]) + "," + str(ISOxICVF[0]) + "," + str(ISOxODI[0]) + "," + str(ISOxRTOP[0]) + "," + str(ISOxRTPP[0]) + "," + str(ISOxRTAP[0]) + "," + str(FAxICVF[0]) + "," + str(FAxRTOP[0]) + "," + str(FAxAD[0]) + "," + str(FAxMD[0]) + "," + str(FAxODI[0]) + "," + str(FAxRD[0]) + "," + str(FAxRTAP[0]) + "," + str(FAxRTPP[0]) + "," + str(ICVFxRTOP[0]) + "," + str(ICVFxAD[0]) + "," + str(ICVFxMD[0]) + "," + str(ICVFxODI[0]) + "," + str(ICVFxRD[0]) + "," + str(ICVFxRTAP[0]) + "," + str(ICVFxRTPP[0]) + "," + str(RTOPxAD[0]) + "," + str(RTOPxMD[0]) + "," + str(RTOPxODI[0]) + "," + str(RTOPxRD[0]) + "," + str(RTOPxRTAP[0]) + "," + str(RTOPxRTPP[0]) + "," + str(ADxMD[0]) + "," + str(ADxODI[0]) + "," + str(ADxRD[0]) + "," + str(ADxRTAP[0]) + "," + str(ADxRTPP[0]) + "," + str(MDxODI[0]) + "," + str(MDxRD[0]) + "," + str(MDxRTAP[0]) + "," + str(MDxRTPP[0]) + "," + str(ODIxRD[0]) + "," + str(ODIxRTAP[0]) + "," + str(ODIxRTPP[0]) + "," + str(RDxRTAP[0]) + "," + str(RDxRTPP[0]) + "," + str(RTAPxRTPP[0]) + "\n"

print(myCsvRow)

# make the .csv with the desired name beforehand (instead of cors_6_19.csv)

print(nib.aff2axcodes(icvf_can.affine))
with open('/home/apines/cors_6_19_replicate.csv','a') as fd:
    fd.write(myCsvRow)

