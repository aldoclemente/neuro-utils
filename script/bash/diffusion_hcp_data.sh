#!/bin/bash

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
   case $option in
      h) # display Help
         help
         exit;;
      s) 
         m=$OPTARG;;
      o) 
      	OUTDIR=$OPTARG;;   
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

if ! [ -d $OUTDIR/Diffusion/ ]; then
  mkdir $OUTDIR/Diffusion/
fi

# download data
while read subject; do
    if ! [ -d $OUTDIR/Diffusion/${subject} ]; then
        mkdir $OUTDIR/Diffusion/${subject}
        aws s3 sync s3://hcp-openaccess/HCP/$subject/T1w/Diffusion $OUTDIR/Diffusion/${subject}
        aws s3 cp s3://hcp-openaccess/HCP/$subject/MNINonLinear/xfms/acpc_dc2standard.nii.gz $OUTDIR/Diffusion/${subject} 
    fi
done < input_idxs.txt

# fit DTI using FSL
while read subject; do
	if ! [ -d $OUTDIR/Diffusion/${subject}/fsl ]; then
		mkdir $OUTDIR/Diffusion/${subject}/fsl
		dtifit -k Diffusion/${subject}/data.nii.gz -m $OUTDIR/Diffusion/${subject}/nodif_brain_mask.nii.gz -r $OUTDIR/Diffusion/${subject}/bvecs -b $OUTDIR/Diffusion/${subject}/bvals --save_tensor -o $OUTDIR/Diffusion/${subject}/fsl/dti
	fi
done < input_idxs.txt

# apply non-linear transf using FSL
while read subject; do
	if ! [ -d $OUTDIR/Diffusion/${subject}/acpc_dc2standard ]; then
        mkdir $OUTDIR/Diffusion/${subject}/acpc_dc2standard
        applywarp --in=$OUTDIR/Diffusion/${subject}/fsl/dti_tensor.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=$OUTDIR/Diffusion/${subject}/acpc_dc2standard.nii.gz --out=$OUTDIR/Diffusion/${subject}/acpc_dc2standard/dti_tensor.nii.gz
        applywarp --in=$OUTDIR/Diffusion/${subject}/fsl/dti_V1.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=$OUTDIR/Diffusion/${subject}/acpc_dc2standard.nii.gz --out=$OUTDIR/Diffusion/${subject}/acpc_dc2standard/dti_V1.nii.gz
    fi
done < input_idxs.txt

rm input_idxs.txt



