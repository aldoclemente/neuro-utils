#!/bin/bash

ID=$1                               #subjects id in /path/to/freesurfer/subjects #cvs_avg35_inMNI152
INPUTDIR=$SUBJECTS_DIR/$ID

UTILS=$(pwd)/../python             #$HOME/Desktop/neuro-utils/script/python
OUTDIR=$(pwd)/../../data/$ID
STL=$OUTDIR/stl

mkdir -p $OUTDIR
mkdir -p $STL

SURFS=(lh.pial rh.pial lh.white rh.white)

for SURF in ${SURFS[@]}; do
    mkdir -p $STL/$SURF
    mris_convert $INPUTDIR/surf/$SURF $STL/$SURF/$SURF.stl
done

for SURF in ${SURFS[@]}; do 
    ./build_smooth_surface.sh $STL/$SURF/$SURF.stl 
done 


docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ --name=svmtk -dit aldoclemente/svmtk

docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/stl/lh.white/lh.white_repaired.stl \
                                                   --stl_input_2 /output/stl/rh.white/rh.white_repaired.stl \
                                                   --output /output/stl/white.stl
                                                   
docker exec svmtk python3 /utils/merge_hemispheres2.py --stl_input_lh_pial /output/stl/lh.pial/lh.pial_repaired.stl \
                                                 --stl_input_rh_pial /output/stl/rh.pial/rh.pial_repaired.stl \
                                                 --stl_input_white /output/stl/white.stl \
                                                 --output_lh_pial /output/stl/lh_pial.stl \
                                                 --output_rh_pial /output/stl/rh_pial.stl \
                                                 --max_iter 150 # --edge_movement 0.5 --smoothing 0.5 

RESOLUTION=(32 16)
for RES in ${RESOLUTION[@]}; do
    docker exec svmtk python3 /utils/create_two_domain_tagged_mesh2.py -silp /output/stl/lh_pial.stl \
                                                -sirp /output/stl/rh_pial.stl \
                                                -siw /output/stl/white.stl \
                                                --output /output/$ID.brain.$RES.mesh -r $RES
                                                
    docker exec svmtk meshio convert /output/$ID.brain.$RES.mesh /output/$ID.brain.$RES.vtu
done

docker stop svmtk    
