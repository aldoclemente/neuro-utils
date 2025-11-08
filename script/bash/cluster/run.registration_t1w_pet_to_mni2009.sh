#!/bin/bash

adni3data=$HOME/ADNI3-cohort
inputfile=$adni3data/$1
scripts=$HOME/neuro-utils/script/bash/cluster
logs=$adni3data/logs
mkdir -p $logs

while read -r subj; do
qsub -N reg-$subj -v subject=$subj -o $logs/out.reg-MNI152-$subj.txt -e $logs/err.reg-MNI152-$subj.txt $scripts/registration_t1w_pet_to_mni2009.sh 
done < $inputfile


