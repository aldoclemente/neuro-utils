#! /bin/bash

cd $1

T1DIR="T1w"
PETDIR="PET"
DTIDIR="DTI" 
DIRS=($T1DIR $PETDIR $DTIDIR)

for sub in *; do
	cd $sub 
    for DIR in ${DIRS[@]}; do
        cd $DIR
        for date in */; do
            cd $date
            rm -rf */
            cd ..		
	    done
	    cd ..
	done
	cd ..	
done
