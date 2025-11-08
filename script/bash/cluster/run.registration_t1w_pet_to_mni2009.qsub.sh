#!/bin/bash

#PBS -S /bin/bash
#PBS -l select=1:ncpus=96:mpiprocs=48,walltime=24:00:00
#PBS -j oe
#PBS -N reg-MNI152

adni3data=$HOME/ADNI3-cohort
inputfile=$adni3data/$1
scripts=$HOME/neuro-utils/script/bash/cluster
logs=$adni3data/logs
mkdir -p $logs

START=$(date +%s)

while read -r subj; do
./$scripts/registration_t1w_pet_to_mni2009.sh $subj > $logs/out.reg-MNI152_2009-$subj.txt &
done < $inputfile

echo registration time $(( $(date +%s) - $START )) secs > output.txt

