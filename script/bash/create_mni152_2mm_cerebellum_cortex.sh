
ID=fsl_mni152_2mm
neuro_utils=/home/aldoclemente/Desktop/neuro-utils
APARC_ASEG_MNI152_2mm=$SUBJECTS_DIR/$ID/mri/aparc+aseg.mgz
aparc_aseg_mni152_2mm_nii=$neuro_utils/data/$ID/nifti/aparc+aseg.nii.gz 
mri_convert $APARC_ASEG_MNI152_2mm $aparc_aseg_mni152_2mm_nii

lh_cerebellum_cortex_mni152_2mm=$neuro_utils/data/$ID/nifti/lh_cerebellum_cortex_mask.nii.gz
rh_cerebellum_cortex_mni152_2mm=$neuro_utils/data/$ID/nifti/rh_cerebellum_cortex_mask.nii.gz
cerebellum_cortex_mni152_2mm=$neuro_utils/data/$ID/nifti/cerebellum_cortex_mask.nii.gz

cerebral_mask=$neuro_utils/data/$ID/nifti/cerebral_mask.nii.gz

#fslmaths $aparc_aseg_mni152_2mm_nii -thr 8 -uthr 8 -bin $lh_cerebellum_cortex_mni152_2mm
#fslmaths $aparc_aseg_mni152_2mm_nii -thr 47 -uthr 47 -bin $rh_cerebellum_cortex_mni152_2mm
#fslmaths $lh_cerebellum_cortex_mni152_2mm -add $rh_cerebellum_cortex_mni152_2mm -bin $cerebellum_cortex_mni152_2mm

idxs=(41 77 251 252 253 254 255 7 46 4 5 14 43 44 72 31 63 3 42) # 2 
fslmaths $aparc_aseg_mni152_2mm_nii -thr 2 -uthr 2 -bin $cerebral_mask
tmp=tmp.nii.gz
for id in ${idxs[@]}; do
    fslmaths $aparc_aseg_mni152_2mm_nii -thr $id -uthr $id -bin $tmp
    fslmaths $cerebral_mask -add $tmp -bin $cerebral_mask
done

rm $tmp
