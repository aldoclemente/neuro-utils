#!/bin/bash 

adni3data=/media/aldoclemente/EXTERNAL_USB/data/nonlinear/ADNI3-cohort
T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 
UTILSDIR=$HOME/neuro-utils
#FSL=$HOME/fsl_latest.sif
#FSLDIR=/usr/local/fsl         # !!!
#export FSLOUTPUTTYPE=NIFTI_GZ # !!!
#APPTAINER=/opt/mox/apptainer/bin/apptainer
ref=/home/aldoclemente/Desktop/neuro-utils/data/mni152simnibs/nifti/T1.nii.gz

cd $adni3data/$1
echo registering subject $1 ...
cd $T1DIR
for k in */; do
    cd $k
    # sub-specific T1 to ref (linear)
    flirt -ref $ref -in anat.anat/T1_biascorr.nii.gz -out T1_to_mni152simnibs_linear.nii.gz -omat T1_to_mni152simnibs_affine.mat
    
 	#fnirt --in=anat.anat/T1_biascorr.nii.gz --aff=affine_transf.mat --cout=T1_to_MNI2009_nonlin_field.nii.gz --config=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/config-cluster
 	#fsl applywarp --ref=$ref --in=anat.anat/T1_biascorr.nii.gz --warp=T1_to_MNI2009_nonlin_field.nii.gz --out=T1_to_MNI2009_nonlin.nii.gz
    cd ..
done
cd .. # sub

# PET registration
cd $PETDIR
for k in */; do
    cd $k
    
    # linear registering sub-specific PET to corresponding T1w
    flirt -in unwarped.nii.gz -ref ../../$T1DIR/$k/anat.anat/T1_biascorr.nii.gz -o warped.nii.gz
    
    # linear registration to ref
    flirt -in warped.nii.gz -ref $ref -applyxfm -init ../../$T1DIR/$k/T1_to_mni152simnibs_affine.mat -out PET_to_mni152simnibs_linear.nii.gz
    cd ..
done
echo done
