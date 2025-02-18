
#! /bin/bash

cd ADNI

T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 

for sub in `ls`; do
	cd $sub 
	
	# T1w
	cd $T1DIR
	for date in */; do
		dcm2niix -f unwarped -z y -o $date/ $date/*/ # DOVREBBERO essere OK
	done
	
	cd .. # $sub
	# ---
	
	# PET
	cd $PETDIR
	for date in */; do
		dcm2niix -f unwarped -z y -o $date/ $date/*/  # queste sono preprocessate
	done
	
	cd ..
	# ---
	
	# DTI
	cd $DTIDIR
	for date in */; do
		dcm2niix -f raw -z y -o $date/ $date/*/ # devi eddy correggerle  
	done
	
	cd .. # $sub
	# ---
	
	cd .. # ADNI
done
