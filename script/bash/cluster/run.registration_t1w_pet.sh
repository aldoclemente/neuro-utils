#!/bin/bash

cd $HOME/ADNI3-cohort
INPUTFILE=$HOME/ADNI3-cohort/$inputfile

mkdir -p logs

while read -r subject; do
qsub -N reg-$subject -v subj=$subject -o logs/out.reg-MNI152-$subject.txt -e logs/err.reg-MNI152-$subject.txt registration_t1w_pet.sh 
done < $inputfile


