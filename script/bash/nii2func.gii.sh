#!/bin/bash

help()
{
    echo "Usage: ./nii2gii.sh [-i|h]
       -i          input directory
       -h 		   shows this message"
    exit 2
}

INPUTDIR="."

while getopts "hi:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      i) 
      	INPUTDIR=$OPTARG;;   
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

cd $INPUTDIR
OUTGIIDIR="$(basename $INPUTDIR)_gii" 

cd ../

if ! [ -d $OUTGIIDIR ]; then
  mkdir $OUTGIIDIR
fi

if ! [ -d $OUT1dDIR ]; then
  mkdir $OUT1dDIR
fi

for filename in $INPUTDIR/*.nii; do
    wb_command -cifti-separate "$filename" COLUMN -metric CORTEX_LEFT $OUTGIIDIR/$(basename "$filename" .nii).func.gii
done



