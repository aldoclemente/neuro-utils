#!/bin/bash

user="$(whoami)"
m=${1:-1}
head -$m subject_idxs.txt > input_idxs.txt

if ! [ -d Diffusion/ ]; then
  mkdir Diffusion/
fi

# download data
while read subject; do
    if ! [ -d Diffusion/${subject} ]; then
        mkdir Diffusion/${subject}
        aws s3 sync s3://hcp-openaccess/HCP/$subject/T1w/Diffusion Diffusion/${subject}
        aws s3 cp s3://hcp-openaccess/HCP/$subject/MNINonLinear/xfms/acpc_dc2standard.nii.gz Diffusion/${subject} 
    fi
done < input_idxs.txt

# fit DTI using FSL
while read subject; do
	if ! [ -d Diffusion/${subject}/fsl ]; then
		mkdir Diffusion/${subject}/fsl
		dtifit -k Diffusion/${subject}/data.nii.gz -m Diffusion/${subject}/nodif_brain_mask.nii.gz -r Diffusion/${subject}/bvecs -b Diffusion/${subject}/bvals --save_tensor -o Diffusion/${subject}/fsl/dti
	fi
done < input_idxs.txt

# apply non-linear transf using FSL
while read subject; do
	if ! [ -d Diffusion/${subject}/acpc_dc2standard ]; then
        mkdir Diffusion/${subject}/acpc_dc2standard
        applywarp --in=Diffusion/${subject}/fsl/dti_tensor.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=Diffusion/${subject}/acpc_dc2standard.nii.gz --out=Diffusion/${subject}/acpc_dc2standard/dti_tensor.nii.gz
        applywarp --in=Diffusion/${subject}/fsl/dti_V1.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=Diffusion/${subject}/acpc_dc2standard.nii.gz --out=Diffusion/${subject}/acpc_dc2standard/dti_V1.nii.gz
    fi
done < input_idxs.txt






