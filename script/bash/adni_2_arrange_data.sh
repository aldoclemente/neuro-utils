#!/bin/bash

cd $1

T1DIR="T1w"
T1RAWDIR="Accelerated_Sagittal_MPRAGE"

PETDIR="PET"
PETRAWDIR="AV1451_Coreg,_Avg,_Std_Img_and_Vox_Siz,_Uniform_Resolution"

DTIDIR="DTI" 
DTIRAWDIR1="Axial_DTI"
DTIRAWDIR2="Axial_MB_DTI"

DIRS=($T1DIR $PETDIR $DTIDIR)

for sub in *; do
	cd $sub
		
    for DIR in ${DIRS[@]}; do
        if ! [ -d $DIR ]; then
		    mkdir $DIR
	    fi
	done 
	
	if [ -d $T1RAWDIR ]; then
		mv $T1RAWDIR/* $T1DIR/
		rm -r $T1RAWDIR
	fi
		
	if [ -d $PETRAWDIR ]; then
		mv  $PETRAWDIR/* $PETDIR/
		rm -r $PETRAWDIR
	fi
		
	if [ -d $DTIRAWDIR1 ]; then
		mv $DTIRAWDIR1/* $DTIDIR/
		rm -r $DTIRAWDIR1
	fi
		
	if [ -d $DTIRAWDIR2 ]; then
		mv $DTIRAWDIR2/* $DTIDIR/
		rm -r $DTIRAWDIR2
	fi
	
	# get rid of dates
	for DIR in ${DIRS[@]}; do
	k=0
	cd $DIR
	    for date in */; do
		mv $date $k
	    k=$(($k+1))
    	done 	
	cd ..
	done
	
	cd .. 
done

