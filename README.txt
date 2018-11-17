This is a set of scripts to take raw diffusion data from preprocessing to scalars, weighted connectivity matrices, network metrics, etc.

Seperated into two main branches:

----------------------------
Preprocessing:
-----------------------------
Raw DWI -> Quality assurance, motion correction, phase-encoding distortion correction, eddy current correction, coregistration to structurals, template, NODDI scalars via AMICO framework : Multishell_Preproc.sh
----------------------------
-----------------------------


----------------------------
Postprocessing - Scalar stuff
-----------------------------
corrected DWI -> rt*p scalars (from mapmri/mapl), MCMDI scalars, and extrapolated diffusion data : mapl_extrap.py

extrapolated DWI -> mcdmi fit : mcdmi_extrap.py

scalars -> stats on scalars in jhu ROIs : jhu_tractstats.sh
-----------------------------
-----------------------------

-----------------------------
Postprocessing - Network stuff
-----------------------------
corrected DWI-> deterministic tractography, connectivity matrices, Fractional anisotropy scalars via Camino : determtract.sh

connectivity matrices -> global efficiency and mean strength : Wrap_global_eff.m

connectivity matrices -> Within and between network connectivity : WithinMConn.m

connectivity matrices -> Participation coefficients: partcoefwrap.m
-----------------------------
-----------------------------
+++++++++++++
++Workflow+++
+++++++++++++

Preprocess,DetermTract,QA and missings if needed, squareform_new, grouplevel participation coeff, withinM_Conn_Scalar
