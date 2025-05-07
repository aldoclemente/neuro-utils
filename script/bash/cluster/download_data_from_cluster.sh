#!/bin/bash 


STATUS=$(globalprotect show --status)
CONNECTED=0
#if [[ "$STATUS" == "GlobalProtect status: Disconnected" ]]; then
if echo "$STATUS" | grep -q "Disconnected"; then
    globalprotect connect --portal gp-dmat.vpn.polimi.it
else 
    CONNECTED=1
fi

T1DIR="T1w"
PETDIR="PET"
DATADIR=/media/aldoclemente/EXTERNAL_USB/data/nonlinear/ADNI3-cohort

INPUTFILE=$1

DIRS=($T1DIR $PETDIR)
K=(0 1 2)
while read -r subject; do    
    for DIR in ${DIRS[@]}; do
        for k in ${K[@]}; do
            PATHdir=$subject/$DIR/$k 
            scp clemente@10.78.17.10:/u/clemente/ADNI3-cohort/$PATHdir/warped.nii.gz $DATADIR/$PATHdir/warped.nii.gz # clemente @ kami.inside.mate.polimi.it
            sleep 2
        done
    done
    
    for k in ${K[@]}; do
        PATHdir=$subject/T1w/$k 
        scp clemente@10.78.17.10:/u/clemente/ADNI3-cohort/$PATHdir/unwarped_bet.nii.gz $DATADIR/$PATHdir/
        sleep 2
        
        scp clemente@10.78.17.10:/u/clemente/ADNI3-cohort/$PATHdir/unwarped_bet_mask.nii.gz $DATADIR/$PATHdir/
        sleep 2
        
        scp clemente@10.78.17.10:/u/clemente/ADNI3-cohort/$PATHdir/affine_transf.mat $DATADIR/$PATHdir/
        sleep 2
        
        scp clemente@10.78.17.10:/u/clemente/ADNI3-cohort/$PATHdir/nonlinear_transf.nii.gz $DATADIR/$PATHdir/
        sleep 2
    done
done < $DATADIR/$INPUTFILE #ADNI3-cohort_subjects.txt

if [[ $CONNECTED == 0 ]]; then
    globalprotect disconnect
fi
