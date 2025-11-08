#!bin/bash

SUBJECTS_DIR=$HOME/.freesurfer/subjects/

#ID=mni_icbm152_nlin_asym_09c
#DATA=$HOME/neuro-utils/data/$ID/nifti
#T1=$DATA/mni_icbm152_t1_tal_nlin_asym_09c.nii
#T2=$DATA/mni_icbm152_t2_tal_nlin_asym_09c.nii

APPTAINER=/opt/mox/apptainer/bin/apptainer
IMG=$HOME/freesurfer_7.4.1.sif

LICENSE=$HOME/.freesurfer/license.txt

cd $subject

T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 
UTILSDIR=$HOME/neuro-utils
FSL=$HOME/fsl_latest.sif
export FSLOUTPUTTYPE=NIFTI_GZ # !!!
APPTAINER=/opt/mox/apptainer/bin/apptainer

if [ -d $SUBJECTS_DIR/$subject ]; then rm -r $SUBJECTS_DIR/$subject; fi

cd $T1DIR
for k in */; do
    $APPTAINER exec $FSL bet unwarped.nii.gz unwarped_bet.nii.gz -B -f 0.15
    
#$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $ID -i $T1 -T2 $T2 -all

$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $ID -i $T1  -all


