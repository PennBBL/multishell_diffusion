#!/bin/bash
# ---------------------------------------------------------------
# QA_DTI.sh - do QA on DTI 4D Nifti
#   returns tab delimited QA metrics file
#
# NOTE: This version handles multiple b-value shells
#
# M. Elliott - 2017
# ### Added edited imglob 2/19/19 bc it calls unspecified python, defaults to v3, and breaks via print

# --------------------------
Usage() {
	echo "usage: `basename $0` [-append] [-keep] <4Dinput> <bvals> <bvecs> [<maskfile>] <resultfile>"
    exit 1
}
# --------------------------

# --- Perform standard qa_script code ---
source /data/joy/BBL/tutorials/code/multishell_diffusion/PreProc/qa_preamble.sh

# --- Parse inputs ---
if [ $# -lt 4 -o $# -gt 5 ]; then Usage; fi
infile=`/data/joy/BBL/tutorials/code/multishell_diffusion/PreProc/imglob -extension $1`
if [ "X$infile" == "X" ]; then echo "ERROR: Cannot find file $1 or it is not a NIFTI file."; exit 1; fi
indir=`dirname $infile`
inbase=`basename $infile`
inroot=`remove_ext $inbase`
bvalfile=$2
bvecfile=$3
maskfile=""
if [ $# -gt 4 ]; then
    maskfile=`/data/joy/BBL/tutorials/code/multishell_diffusion/PreProc/imglob -extension $4`
    shift
fi
resultfile=$4
outdir=`dirname $resultfile`

# Added in 2/27/19 AP to override not being able to find version number
VERSION=3
#####

# --- start result file ---
if [ $append -eq 0 ]; then 
    echo -e "modulename\t$0"      > $resultfile
    echo -e "version\t$VERSION"  >> $resultfile
    echo -e "inputfile\t$infile" >> $resultfile
fi

# --- find number of unique bvals ---
bvals=`cat $bvalfile`
bvals=`echo $bvals | sed -e 's/^[ \t]*//'`    		# remove any initial white space!!
#echo -e "${bvals// /\\n}" | sort -b -n -u			# this outputs unique bvals, one per line
#echo $(echo -e "${bvals// /\\n}" | sort -b -n -u)	# this outputs unique bvals on one line
unique_bvals=(`echo $(echo -e "${bvals// /\\n}" | sort -b -n -u)`)
nunique_bvals=${#unique_bvals[@]}
echo "Found $nunique_bvals unique bvals: (${unique_bvals[@]})"
if [ ${unique_bvals[0]} != "0" ]; then
	echo "ERROR: There is no bval = 0 shell!. Cannot perform QA."
	exit 1
fi

# --- Create separate NIFTIs for each bval shell ---
bvals=(`cat $bvalfile`)
nvols=${#bvals[@]}
b0count=0
bxcount=0
rm -f $outdir/${inroot}_b*_tmp*.nii
echo "Separating input NIFTI of $nvols volumes into $nunique_bvals NIFTIs, one for each bval shell..."
for (( i=0; i<$nvols; i++ )) ; do
    echo -n "."
	ipadded=`printf "%4.4d" $i`	# this is so the tmp files list in the correct order by volume
	tmpfile=$outdir/${inroot}_b${bvals[$i]}_tmp${ipadded}.nii
#	echo $tmpfile
	3dcalc -prefix $tmpfile -a${i} $infile -expr 'a' 2>/dev/null
done
echo "."

# --- now concatenate by shell ---
count_list=""
for (( i=0; i<$nunique_bvals; i++ )) ; do
	bval=${unique_bvals[$i]}
	outfile=$outdir/${inroot}_b${bval}.nii
	rm -f $outfile
	3dTcat -prefix $outfile $outdir/${inroot}_b${bval}_tmp*.nii 2>/dev/null
	count=`ls -l $outdir/${inroot}_b${bval}_tmp*.nii | wc -l`
	echo "bval = $bval: found $count volumes"
	count_list="$count_list $count"
done

# --- mask from b=0 shell ---
if [ "X${maskfile}" = "X" ]; then
    echo "Automasking from bval = 0 volumes..." 
    maskfile=${outdir}/${inroot}_qamask.nii
    rm -f $maskfile
    3dAutomask -prefix $maskfile $outdir/${inroot}_b0.nii  2>/dev/null
fi

# --- find clipped voxels ---
echo "Finding clipped voxels..."
${EXECDIR}qa_clipcount_v${VERSION}.sh -append $keepswitch $infile $maskfile $resultfile
clipmask=${outdir}/${inroot}_clipmask.nii    # this will be the clipmask result

# --- Remove clipped voxels from TSNR estimates ---
tsnrmask=${outdir}/${inroot}_tsnrmask.nii
fslmaths $clipmask -sub 1 -abs -mul $maskfile $tsnrmask

# --- QA each shell ---
for (( i=0; i<$nunique_bvals; i++ )) ; do
	bval=${unique_bvals[$i]}
	infile=$outdir/${inroot}_b${bval}.nii

	echo "Computing moco metrics on bval = $bval shell..."
	###
	echo ${EXECDIR}qa_motion_v${VERSION}.sh -append -subfield _b${bval} $keepswitch $infile $resultfile
	###
	${EXECDIR}qa_motion_v${VERSION}.sh -append -subfield _b${bval} $keepswitch $infile $resultfile

	echo "Computing tsnr metrics on bval = $bval shell..."
	${EXECDIR}qa_tsnr_v${VERSION}.sh -append -subfield _b${bval} $keepswitch $infile $tsnrmask $resultfile
	#echo ${bval}>>/data/joy/BBL/projects/multishell_diffusion/processedData/TSNR.csv
	if [ $keep -eq 0 ]; then rm -f $infile; fi
done

# make mean moco'd b=0 image
#echo "Computing mean motion-corrected bval = 0 shell..."
#fslmaths $outdir/${inroot}_b0_mc -Tmean ${outdir}/${inroot}_b0_mc_mean -odt float

# --- clean up ---
if [ $keep -eq 0 ]; then
	rm -f $outdir/${inroot}_b*_tmp*.nii $tsnrmask
fi
exit 0
