#!/bin/bash 

#PBS -S /bin/bash
#PBS -l select=1:ncpus=2:mpiprocs=1,walltime=08:00:00
#PBS -j oe

adni3data=$HOME/ADNI3-cohort
T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 
UTILSDIR=$HOME/neuro-utils
FSL=$HOME/fsl_latest.sif
FSLDIR=/usr/local/fsl         # !!!
export FSLOUTPUTTYPE=NIFTI_GZ # !!!
APPTAINER=/opt/mox/apptainer/bin/apptainer
mni=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c.nii

cd $adni3data
START=$(date +%s)
#while read -r subject; do
# T1w registration
cd $subject
cd $T1DIR
for k in */; do
    cd $k
    # if you want to register to another template, avoid registration to MNI152_2mm (default FSL) 
    # use --nononlinreg to avoid nonlinear registration and use fnirt (you should provide a configuration file!)
    # see FSL documention
    #if [ -d anat.anat ]; then rm -r anat.anat; fi
    #$APPTAINER exec $FSL fsl_anat -i unwarped.nii.gz -o anat
    $APPTAINER exec $FSL flirt -ref $UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz \
 	    -in anat.anat/T1_biascorr_brain.nii.gz -omat affine_transf.mat
 	$APPTAINER exec $FSL fnirt --in=anat.anat/T1_biascorr.nii.gz --aff=affine_transf.mat --cout=T1_to_MNI2009_nonlin_field.nii.gz --config=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/config
 	$APPTAINER exec $FSL applywarp --ref=$mni --in=anat.anat/T1_biascorr.nii.gz --warp=T1_to_MNI2009_nonlin_field.nii.gz --out=T1_to_MNI2009_nonlin.nii.gz
    cd ..
done
cd .. # sub

# PET registration
cd $PETDIR
for k in */; do
    cd $k
    # setting -dof 6 (default 12!) see FSL documentation
    $APPTAINER exec $FSL flirt -ref ../../$T1DIR/$k/T1_to_MNI2009_nonlin.nii.gz -in unwarped.nii.gz -dof 6 -omat func2struct.mat
    $APPTAINER exec $FSL applywarp --ref=$mni --in=unwarped.nii.gz --warp=../../$T1DIR/$k/T1_to_MNI2009_nonlin_field.nii.gz --premat=func2struct.mat --out=PET_to_MNI2009_nonlin.nii.gz
    cd ..
done
echo registration time $(( $(date +%s) - $START )) secs 
