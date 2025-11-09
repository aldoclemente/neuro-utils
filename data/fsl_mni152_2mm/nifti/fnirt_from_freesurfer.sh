#!/bin/bash
# le maschere create da freesurfer hanno tutte risoluzione 256 x 256 x 256
# quind ...
#RUN script/bash/create_cerebellum_cortex_cerebral_masks.sh
ID=fsl_mni152_2mm
brain=${FSLDIR}/data/standard/MNI152_T1_2mm_brain.nii.gz
ref=${FSLDIR}/data/standard/MNI152_T1_2mm.nii.gz
outdir=fnirt
mkdir -p $outdir

sudo cp /usr/local/freesurfer/7.4.1/subjects/$ID/mri/T1.mgz $outdir/T1_freesurfer.mgz
sudo cp /usr/local/freesurfer/7.4.1/subjects/$ID/mri/brain.mgz $outdir/brain_freesurfer.mgz
mri_convert $outdir/T1_freesurfer.mgz $outdir/T1_freesurfer.nii.gz
mri_convert $outdir/brain_freesurfer.mgz $outdir/brain_freesurfer.nii.gz

fslreorient2std $outdir/T1_freesurfer.nii.gz $outdir/T1_freesurfer.nii.gz
fslreorient2std $outdir/brain_freesurfer.nii.gz $outdir/brain_freesurfer.nii.gz

flirt -ref $brain -in $outdir/brain_freesurfer.nii.gz -omat $outdir/freesurfer2mni_affine.mat
fnirt --in=$outdir/T1_freesurfer.nii.gz --aff=$outdir/freesurfer2mni_affine.mat --cout=$outdir/freesurfer2mni_nonlin_field.nii.gz --config=T1_2_MNI152_2mm

#
applywarp --ref=$ref --in=$outdir/T1_freesurfer.nii.gz --out=$outdir/T1_to_MNI_nonlin.nii.gz --warp=$outdir/freesurfer2mni_nonlin_field.nii.gz

applywarp --ref=$ref --in=$outdir/brain_freesurfer.nii.gz --out=$outdir/brain_to_MNI_nonlin.nii.gz --warp=$outdir/freesurfer2mni_nonlin_field.nii.gz

# cerebellum cortex

fslreorient2std cerebellum_cortex_mask.nii.gz cerebellum_cortex_mask2std.nii.gz
applywarp --ref=$ref --in=cerebellum_cortex_mask2std.nii.gz --out=cerebellum_cortex_mask_to_MNI_nonlin.nii.gz --warp=$outdir/freesurfer2mni_nonlin_field.nii.gz

fslreorient2std cerebral_mask.nii.gz cerebral_mask2std.nii.gz
applywarp --ref=$ref --in=cerebral_mask2std.nii.gz --out=cerebral_mask_to_MNI_nonlin.nii.gz --warp=$outdir/freesurfer2mni_nonlin_field.nii.gz

