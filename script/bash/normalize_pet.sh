#!/bin/bash 

# $1 data dir

DATADIR="$(dirname -- "$(realpath -- "$1")")"
cd $DATADIR
INPUTFILE=$1

T1DIR="T1w"
PETDIR="PET"
UTILSDIR=$HOME/Desktop/neuro-utils

mni152_2mm_cerebellum_cortex_mask=$UTILSDIR/data/fsl_mni152_2mm/nifti/freesurfer.anat/cerebellum_cortex_mask_to_MNI_nonlin.nii.gz

SUVr=$DATADIR/SUVr

if [ -d $SUVr ]; then rm -r $SUVr; fi
mkdir $SUVr

START=$(date +%s)
k=(0 1 2)
while read -r subject; do
    cd $subject
    cd $PETDIR
    for k in */; do
        cd $k
        fslmeants -i PET_to_MNI_nonlin.nii.gz -m $mni152_2mm_cerebellum_cortex_mask -o avg_uptake_cerebellum_cortex.txt
        avg_uptake=$(cat avg_uptake_cerebellum_cortex.txt)
        fslmaths PET_to_MNI_nonlin.nii.gz -div $avg_uptake SUVr_to_MNI_nonlin.nii.gz
        cp SUVr_to_MNI_nonlin.nii.gz $SUVr/SUVr.$subject.${k%/}.nii.gz
        cd ..
    done
    cd .. # sub
    cd ..
done < $INPUTFILE

cd $SUVr
fslmerge -t SUVr_to_MNI_nonlin.nii.gz SUVr.*

echo execution time $(( $(date +%s) - $START )) secs


