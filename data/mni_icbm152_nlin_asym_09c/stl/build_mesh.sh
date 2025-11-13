#!/bin/bash

UTILS=$(pwd)/../../../script/python/
OUTDIR=$(pwd)

setup_freesurfer
docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ --name=svmtk -dit aldoclemente/svmtk

mris_convert $SUBJECTS_DIR/mni_icbm152_nlin_asym_09c/surf/lh.pial lh.orig.pial.stl
mris_convert $SUBJECTS_DIR/mni_icbm152_nlin_asym_09c/surf/rh.pial rh.orig.pial.stl
cp lh.orig.pial.stl lh.pial.stl
cp rh.orig.pial.stl rh.pial.stl

mri_binarize --i $SUBJECTS_DIR/mni_icbm152_nlin_asym_09c/mri/aseg.mgz --match 251 252 253 254 255 --o corpo_callosum.mgz
mri_morphology corpo_callosum.mgz fill_holes 1 corpo_callosum.mgz
mri_binarize --i corpo_callosum.mgz --match 1 --surf-smooth 10 --surf corpo_callosum.stl

docker exec svmtk python3 /utils/separate_surface.py --stl_input_1 /output/lh.pial.stl \
                                                  --stl_input_2 /output/rh.pial.stl \
                                                  --adjustment 5

docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output//lh.pial.stl \
                                                  --stl_input_2 /output/corpo_callosum.stl \
                                                  --output /output/lh.pial-cc.stl
                                                  
docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/lh.pial-cc.stl \
                                                  --stl_input_2 /output/rh.pial.stl \
                                                  --output /output/pial.stl

mkdir -p mesh

# pial.clean.stl (using 3d Slicer)
input=/output/pial.clean.stl
declare -a res=(32 64) #(8 16 20 24) # 32 64)
for r in "${res[@]}"; do
    output=/output/mesh/mesh.$r.mesh
    docker exec svmtk python3 /utils/create_volume_mesh.py -i $input -o $output -r $r 
done

for r in "${res[@]}"; do
    input=/output/mesh/mesh.$r.mesh
    output=/output/mesh/mesh.$r
    docker exec svmtk meshio convert $input $output.vtu
    docker exec svmtk meshio convert $input $output.xdmf
    docker exec svmtk gmsh $input -format msh2 -save $output.msh 
done


docker exec svmtk chown -R 1000:1000 /output 
docker stop svmtk                                                