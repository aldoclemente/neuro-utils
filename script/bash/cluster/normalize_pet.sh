#!/bin/bash 

#PBS -S /bin/bash
#PBS -l nodes=1:ppn=96,walltime=48:00:00
#PBS -N SUVr-MNI152

INPUTFILE=$HOME/ADNI3-cohort/$inputfile

T1DIR="T1w"
PETDIR="PET"
UTILSDIR=$HOME/neuro-utils
FSL=$HOME/fsl_latest.sif
FSLDIR=/usr/local/fsl         # !!!
export FSLOUTPUTTYPE=NIFTI_GZ # !!!
APPTAINER=/opt/mox/apptainer/bin/apptainer

mni152_2mm_cerebellum_cortex_mask=$UTILSDIR/data/fsl_mni152_2mm/nifti/freesurfer.anat/cerebellum_cortex_mask_to_MNI_nonlin.nii.gz

START=$(date +%s)

while read -r subject; do
    cd $subject
    cd $PETDIR
    for k in */; do
        cd $k
        $APPTAINER exec $FSL fslmeants -i PET_to_MNI_nonlin.nii.gz -m $mni152_2mm_cerebellum_cortex_mask \ 
                                        -o avg_uptake_cerebellum_cortex.txt
        avg_uptake=$(cat avg_uptake_cerebellum_cortex.txt)
        $APPTAINER exec $FSL fslmaths PET_to_MNI_nonlin.nii.gz -div $avg_uptake SUVr_to_MNI_nonlin.nii.gz
        cd ..
    done
    cd ..
done < $INPUTFILE
echo execution time $(( $(date +%s) - $START )) secs


