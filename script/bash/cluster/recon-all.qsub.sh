#!/bin/bash

#PBS -S /bin/bash
#PBS -l nodes=1:ppn=96,walltime=48:00:00
#PBS -N recon-all

SUBJECTS_DIR=$HOME/.freesurfer/subjects/
#ID=mni_icbm152_nlin_asym_09c
#DATA=$HOME/neuro-utils/data/$ID/nifti
#T1=$DATA/mni_icbm152_t1_tal_nlin_asym_09c.nii
#T2=$DATA/mni_icbm152_t2_tal_nlin_asym_09c.nii

ID=fsl_mni152_1mm
DATA=$HOME/neuro-utils/data/$ID/nifti
T1=$DATA/MNI152_T1_1mm.nii.gz

APPTAINER=/opt/mox/apptainer/bin/apptainer
IMG=$HOME/freesurfer_7.4.1.sif

LICENSE=$HOME/.freesurfer/license.txt

if [ -d $SUBJECTS_DIR/$ID ]; then rm -r $SUBJECTS_DIR/$ID; fi
    
#$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $ID -i $T1 -T2 $T2 -all
START=$(date +%s)
$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $ID -i $T1 -all
echo execution time $(( $(date +%s) - $START )) secs
