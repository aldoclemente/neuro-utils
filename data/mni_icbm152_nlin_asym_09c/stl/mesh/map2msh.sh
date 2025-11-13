#!/bin/sh

UTILSDIR=$HOME/Desktop/neuro-utils
id=mni_icbm152_nlin_asym_09c
ref=$UTILSDIR/data/${id}/nifti/fnirt/T1_freesurfer.nii.gz
T1DIR="T1w"
datadir=/media/aldoclemente/EXTERNAL_USB/data/nonlinear/ADNI3-cohort
cd $1
subject=$1
K=(0 1 2)
docker run --rm -v $(pwd)/:/output/ --name=svmtk -dit aldoclemente/svmtk
source $HOME/SimNIBS-4.5/simnibs_env/bin/activate
for k in ${K[@]}; do
    slices $datadir/$subject/T1w/$k/T1_to_${id}_linear.nii.gz $ref -o $subject.t1w.$k.slices.png
    nii2msh --type nodes $datadir/$subject/T1w/$k/T1_to_${id}_linear.nii.gz mesh.16.msh $subject.$k.msh
    docker exec svmtk meshio convert /output/$subject.$k.msh /output/$subject.$k.vtu 
done

deactivate
docker exec svmtk chown -R 1000:1000 /output 
docker stop svmtk 