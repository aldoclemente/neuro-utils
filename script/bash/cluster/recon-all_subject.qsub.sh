#!/bin/bash

#PBS -S /bin/bash
#PBS -l nodes=1:ppn=96,walltime=48:00:00
#PBS -N recon-all

# qsub -v subject=..., t1w=/path/to/t1w -o recon-output.txt -e recon-error.txt 
SUBJECTS_DIR=$HOME/.freesurfer/subjects/

APPTAINER=/opt/mox/apptainer/bin/apptainer
IMG=$HOME/freesurfer_7.4.1.sif

LICENSE=$HOME/.freesurfer/license.txt

if [ -d $SUBJECTS_DIR/$ID ]; then rm -r $SUBJECTS_DIR/$subject; fi
    
#$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $ID -i $T1 -T2 $T2 -all
START=$(date +%s)
$APPTAINER exec -B $LICENSE:/usr/local/freesurfer/license.txt -B $SUBJECTS_DIR:/output --env SUBJECTS_DIR=/output/ $IMG recon-all -s $subject -i $t1w -all
echo execution time $(( $(date +%s) - $START )) secs
