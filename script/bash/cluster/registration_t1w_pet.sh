#!/bin/bash 

#PBS -S /bin/bash
#PBS -l nodes=1:ppn=96,walltime=24:00:00
#PBS -j oe
#PBS -N reg-MNI152-2mm

# $subject # path to subject
#cd $subject

cd $HOME/ADNI3-cohort

INPUTFILE=$HOME/ADNI3-cohort/$inputfile

T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 
UTILSDIR=$HOME/neuro-utils
FSL=$HOME/fsl_latest.sif
FSLDIR=/usr/local/fsl         # !!!
export FSLOUTPUTTYPE=NIFTI_GZ # !!!
APPTAINER=/opt/mox/apptainer/bin/apptainer
MNI152T1=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c.nii
MNI152BRAIN=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz
MNI152MASK=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c_mask.nii.gz

START=$(date +%s)

while read -r subject; do
# T1w registration
cd $subject
cd $T1DIR
for k in */; do
    cd $k
    #$APPTAINER exec $FSL bet unwarped.nii.gz unwarped_bet.nii.gz -B -f 0.15 # -B Bias Field & Neck cleanup (necessario)
    $APPTAINER exec $FSL bet unwarped.nii.gz unwarped_bet.nii.gz -B -R #-f 0.15 # -B Bias Field & Neck cleanup (necessario)
    # mni152 2009
	#$APPTAINER exec $FSL flirt -ref $MNI152BRAIN -in unwarped_bet.nii.gz -omat affine_transf.mat
	#$APPTAINER exec $FSL fnirt --in=unwarped.nii.gz --ref=$MNI152BRAIN --refmask=$MNI152MASK --aff=affine_transf.mat --cout=nonlinear_transf --config=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/config
	#$APPTAINER exec $FSL applywarp --ref=$MNI152T1 \
	#	  --in=unwarped.nii.gz --warp=nonlinear_transf --out=warped.nii.gz
    # mni152 2mm 
    $APPTAINER exec $FSL flirt -dof 6 -ref $FSLDIR/data/standard/MNI152_T1_2mm_brain -in unwarped_bet.nii.gz -omat affine_transf.mat
	$APPTAINER exec $FSL fnirt --in=unwarped.nii.gz --aff=affine_transf.mat --cout=nonlinear_transf --config=$FSLDIR/etc/flirtsch/T1_2_MNI152_2mm
	$APPTAINER exec $FSL applywarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm \
		  --in=unwarped.nii.gz --warp=nonlinear_transf --out=warped.nii.gz
    #$APPTAINER exec $FSL slices warped.nii.gz $FSLDIR/data/standard/MNI152_T1_2mm -o $subject.$k.slices.png
    cd ..
done
cd .. # sub

# PET registration
cd $PETDIR
for k in */; do
    cd $k
    # setting -dof 6 (default 12!) see FSL documentation
    $APPTAINER exec $FSL flirt -ref ../../$T1DIR/$k/unwarped_bet.nii.gz -in unwarped.nii.gz -dof 6 -omat func2struct.mat
    # mni152 2009
    #$APPTAINER exec $FSL applywarp --ref=$MNI152T1 --in=unwarped.nii.gz --warp=../../$T1DIR/$k/nonlinear_transf --premat=func2struct.mat --out=warped.nii.gz
    # mni152 2mm
    $APPTAINER exec $FSL applywarp --ref=$FSLDIR/data/standard/MNI152_T1_2mm --in=unwarped.nii.gz --warp=../../$T1DIR/$k/nonlinear_transf --premat=func2struct.mat --out=warped.nii.gz
    cd ..
done
cd .. # sub

cd .. # ADNI3-cohort
done < $INPUTFILE
echo registration time $(( $(date +%s) - $START )) secs 
