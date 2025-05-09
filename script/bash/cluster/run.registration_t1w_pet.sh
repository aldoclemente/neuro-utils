#!/bin/bash

adni3data=$HOME/ADNI3-cohort
inputfile=$adni3data/$1
scripts=$HOME/neuro-utils(script/bash/cluster
logs=$adni3data/logs
mkdir -p $logs

while read -r subject; do
qsub -N reg-$subject -v subj=$subject -o $logs/out.reg-MNI152-$subject.txt -e $logs/err.reg-MNI152-$subject.txt $scripts/registration_t1w_pet.sh 
done < $inputfile


