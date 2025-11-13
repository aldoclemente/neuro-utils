#!/bin/bash

UTILS=$(pwd)/../../script/python/
OUTDIR=$(pwd)

setup_freesurfer
docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ --name=svmtk -dit aldoclemente/svmtk

mri_binarize --i $SUBJECTS_DIR/mni_icbm152_nlin_asym_09c/mri/aseg.mgz --match 251 252 253 254 255 --o corpo_callosum.mgz
mri_morphology corpo_callosum.mgz fill_holes 1 corpo_callosum.mgz
mri_binarize --i corpo_callosum.mgz --match 1 --surf-smooth 10 --surf corpo_callosum.stl

docker exec svmtk python3 /utils/separate_surface.py --stl_input_1 /output/stl/lh.pial.stl \
                                                  --stl_input_2 /output/stl/rh.pial.stl \
                                                  --adjustment 5

docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/stl/lh.pial.stl \
                                                  --stl_input_2 /output/stl/corpo_callosum.stl \
                                                  --output /output/stl/lh.pial-cc.stl
                                                  
docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/stl/lh.pial-cc.stl \
                                                  --stl_input_2 /output/stl/rh.pial.stl \
                                                  --output /output/stl/pial.stl

docker exec svmtk chown -R 1000:1000 /output 
docker stop svmtk                                                