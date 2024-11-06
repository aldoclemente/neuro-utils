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


# Define the number of high-performance cores
NUM_CORES=12

# Define the total number of CPU cores
TOTAL_CORES=$(sysctl -n hw.physicalcpu)

# Calculate the number of cores to be used for parallel processing
PARALLEL_CORES=$((TOTAL_CORES - 4))

# Ensure that PARALLEL_CORES does not exceed the available high-performance cores
if [ "$PARALLEL_CORES" -gt "$NUM_CORES" ]; then
  PARALLEL_CORES=$NUM_CORES
fi

# Define the task function
task_function() {
    # subject index
    subject=$1
    # fit DTI using FSL
    if ! [ -d Diffusion/${subject}/fsl ]; then
        mkdir Diffusion/${subject}/fsl
        dtifit -k Diffusion/${subject}/data.nii.gz -m Diffusion/${subject}/nodif_brain_mask.nii.gz -r Diffusion/${subject}/bvecs -b Diffusion/${subject}/bvals --save_tensor -o Diffusion/${subject}/fsl/dti
    fi
    # apply non-linear transf using FSL
    if ! [ -d Diffusion/${subject}/acpc_dc2standard ]; then
        mkdir Diffusion/${subject}/acpc_dc2standard
        applywarp --in=Diffusion/${subject}/fsl/dti_tensor.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=Diffusion/${subject}/acpc_dc2standard.nii.gz --out=Diffusion/${subject}/acpc_dc2standard/dti_tensor.nii.gz
        applywarp --in=Diffusion/${subject}/fsl/dti_V1.nii.gz --ref=${FSLDIR}/data/standard/MNI152_T1_2mm --warp=Diffusion/${subject}/acpc_dc2standard.nii.gz --out=Diffusion/${subject}/acpc_dc2standard/dti_V1.nii.gz
        mri_convert Diffusion/${subject}/acpc_dc2standard/dti_tensor.nii.gz Diffusion/${subject}/acpc_dc2standard/dti_tensor.nii
    fi
    RScript to_csv.R ${subject}
}

# Export the task function so that it can be used by GNU Parallel
export -f task_function

# Parallel execution
parallel -j "$PARALLEL_CORES" task_function ::: $(<input_idxs.txt)
