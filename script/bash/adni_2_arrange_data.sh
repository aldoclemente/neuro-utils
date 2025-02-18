#!/bin/bash

cd ADNI

T1DIR="T1w"
T1RAWDIR="Accelerated_Sagittal_MPRAGE"

PETDIR="PET"
PETRAWDIR="AV1451_Coreg,_Avg,_Std_Img_and_Vox_Siz,_Uniform_Resolution"

DTIDIR="DTI" 
DTIRAWDIR1="Axial_DTI"
DTIRAWDIR2="Axial_MB_DTI"
#RAWDIR="raw"

for sub in `ls`; do
	cd $sub
	
	#if ! [ -d $RAWDIR ]; then
	#	mkdir $RAWDIR
	#fi
	
	if ! [ -d $T1DIR ]; then
		mkdir $T1DIR
	fi 
	
	if ! [ -d $PETDIR ]; then
		mkdir $PETDIR
	fi 

	if ! [ -d $DTIDIR ]; then
		mkdir $DTIDIR
	fi 
	
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
	
	cd ..
done

