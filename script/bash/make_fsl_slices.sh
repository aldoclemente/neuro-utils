T1DIR="T1w"
OUTDIR=$1/imgs/
cd $1
mkdir -p $OUTDIR
K=(0 1 2)
while read subject; do
    for k in ${K[@]}; do
        slices $subject/T1w/$k/warped.nii.gz $FSLDIR/data/standard/MNI152_T1_2mm -o $OUTDIR/$subject.t1w.$k.slices.png
    done
done < ADNI3-cohort_subjects.txt
