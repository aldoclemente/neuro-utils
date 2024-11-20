#!/bin/bash

user="$(whoami)"

help()
{
    echo "Usage: ./tfMRI_hcp_data.sh [-s|o|h]

       -s          number of subjects 
       -o          output directory
       -h 		   shows this message"
    exit 2
}

OUTDIR=.
m=1

while getopts "hs:o:" option; do
   case "$option" in
      h) # display Help
         help
         exit;;
      s) 
         m=${OPTARG};;
      o) 
      	OUTDIR=${OPTARG};;   
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

if ! [ -d $OUTDIR ]; then
	mkdir $OUTDIR
fi

head -$m subject_idxs.txt > input_idxs.txt

if ! [ -f $OUTDIR/input_idxs.txt ]; then
	cp input_idxs.txt $OUTDIR
fi

cd $OUTDIR

declare -a tfMRI=("tfMRI_GAMBLING_LR" "tfMRI_EMOTION_LR")

for i in "${tfMRI[@]}"; do
	if ! [ -d $OUTDIR/$i ]; then
		mkdir $OUTDIR/$i
	fi
	while read subject; do
		file=$OUTDIR/$i/${subject}.Atlas.dtseries.nii
		if ! [ -f $file ]; then
			aws s3 cp s3://hcp-openaccess/HCP/$subject/MNINonLinear/Results/$i/$i"_"Atlas.dtseries.nii $file
		fi
	done < input_idxs.txt
done

rm input_idxs.txt


