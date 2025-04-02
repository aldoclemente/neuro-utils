#!/bin/bash

mris_convert lh.pial lh.pial.stl
mris_convert rh.pial rh.pial.stl
mris_convert lh.white lh.white.stl
mris_convert lh.white lh.white.stl

mri_binarize --i $SUBJECTS_DIR/cvs_avg35_inMNI152/mri/aparc.a2009s+aseg.mgz --ventricles --o ventricles.mgz
mri_volcluster --in ventricles.mgz --thmin 1 --ocn ventricles_ocn.mgz 
mri_binarize --i ventricles_ocn.mgz --match 1 --o  ventricles.mgz
mri_morphology ventricles.mgz fill_holes 1 ventricles.mgz
mri_binarize --i ventricles.mgz --match 1 --surf-smooth 10 --surf ventricles.stl

mri_binarize --i $SUBJECTS_DIR/cvs_avg35_inMNI152/mri/aparc.a2009s+aseg.mgz --match 15 --o fourth_ventricle.mgz
mri_morphology fourth_ventricle.mgz fill_holes 2 fourth_ventricle.mgz
mri_binarize --i fourth_ventricle.mgz --match 1 --surf-smooth 10 --surf fourth_ventricle.stl

mri_binarize --i $SUBJECTS_DIR/cvs_avg35_inMNI152/mri/aparc.a2009s+aseg.mgz --match 16 --o brain_stem.mgz
mri_morphology brain_stem.mgz fill_holes 1 brain_stem.mgz
mri_binarize --i brain_stem.mgz --match 1 --surf-smooth 10 --surf brain_stem.stl

mri_binarize --i $SUBJECTS_DIR/cvs_avg35_inMNI152/mri/aparc.a2009s+aseg.mgz --match 7 8 46 47 --o cerebellum.mgz
mri_morphology cerebellum.mgz fill_holes 1 cerebellum.mgz
mri_binarize --i cerebellum.mgz --match 1 --surf-smooth 10 --surf cerebellum.stl

# separatamente 

./build_smooth_surface.sh lh.pial.stl
./build_smooth_surface.sh rh.pial.stl
./build_smooth_surface.sh lh.white.stl
./build_smooth_surface.sh rh.white.stl
./build_smooth_surface.sh cerebellum.stl
./build_smooth_surface.sh brain_stem.stl
./build_smooth_surface.sh ventricles.stl

# --------------------------------------------------------------------------------------------------
# pial, white, cerebellum --------------------------------------------------------------------------

UTILS=$HOME/Desktop/neuro-utils/script/python
OUTDIR=$(pwd)
#OUTDIR="$(dirname -- "$(realpath -- "$INPUT")")"

docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ --name=svmtk -dit aldoclemente/svmtk
                                                   
#docker exec svmtk python3 /utils/merge_surfaces.py --stl_input_1 /output/lh.white/lh.white_repaired.stl \
#                                              --stl_input_2 /output/rh.white_repaired.stl \
#                                              --output /output/white.surf.stl                                                   

#docker exec svmtk python3 /utils/merge_surfaces.py --stl_input_1 /output/white.surf.stl \
#                                              --stl_input_2 /output/brain_stem/brain_stem_repaired.stl \
#                                              --output /output/white+brain_stem.surf.stl                                                   

#docker exec svmtk python3 /utils/merge_surfaces.py --stl_input_1 /output/white+brain_stem.surf.stl \
#                                   --stl_input_2 /output/cerebellum/cerebellum_repaired.stl \
#                                   --output /output/white+brain_stem+cerebellum.surf.stl                                                   

# DA FARE
#docker exec svmtk python3 /utils/merge_hemispheres2.py --stl_input_lh_pial /output/lh.pial/lh.pial_repaired.stl \
#                                                      --stl_input_rh_pial /output/rh.pial/rh.pial_repaired.stl \
#                                                      --stl_input_white /output/white.surf.stl \
#                                                      --max_iter 150 --edge_movement -0.5 --smoothing 0.5 \
#                                                      --output_lh_pial /output/lh_pial.surf.stl \
#                                                      --output_rh_pial /output/rh_pial.surf.stl


docker exec svmtk python3 /utils/merge_hemispheres.py --stl_input_lh_pial /output/lh.pial/lh.pial_repaired.stl \
                                                      --stl_input_rh_pial /output/rh.pial/rh.pial_repaired.stl \
                                                      --stl_input_lh_white /output/lh.white/lh.white_repaired.stl \
                                                      --stl_input_rh_white /output/rh.white/rh.white_repaired.stl \
                                                      --max_iter 150 --edge_movement -0.5 --smoothing 0.5 \
                                                      --output_white /output/white_surface.stl \
                                                      --output_lh_pial /output/lh_pial_surface.stl \
                                                      --output_rh_pial /output/rh_pial_surface.stl
                                                      
docker exec svmtk python3 /utils/merge_surfaces.py --stl_input_1 /output/white_surface.stl \
                                                   --stl_input_2 /output/brain_stem/brain_stem_repaired.stl \
                                                   --output /output/white+brain_stem_surface.stl  \
                                                   --adjustment 0.0                                                 
# ADD brain_stem
docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/white_surface.stl \
                                              --stl_input_2 /output/brain_stem/brain_stem_repaired.stl \
                                              --output /output/white+brain_stem.union.surface.stl                                                   

# repair
docker exec svmtk python3 /utils/repaired_surface.py --stl_input /output/white+brain_stem.union.surface.stl --output /output/white+brain_stem.union.surface.stl

mris_info white+brain_stem.union.surface.stl

# ADD cerebellum

docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/white+brain_stem.union.surface.stl \
                                              --stl_input_2 /output/cerebellum/cerebellum_repaired.stl \
                                              --output /output/white+brain_stem+cerebellum.union.surface.stl                                                   

# repair
docker exec svmtk python3 /utils/repaired_surface.py --stl_input /output/white+brain_stem+cerebellum.union.surface.stl --output /output/white+brain_stem+cerebellum.union.surface.stl --adjustment -0.35

mris_info white+brain_stem+cerebellum.union.surface.stl # sono ancora unite..

### Quindi abbiamo due file a disposizione... white.surf.stl & white+brain_stem+cerebellum.surf.stl (attento ai nomi) 

# DA FARE
docker exec svmtk python3 /utils/merge_hemispheres2.py --stl_input_lh_pial /output/lh.pial/lh.pial_repaired.stl \
                                                 --stl_input_rh_pial /output/rh.pial/rh.pial_repaired.stl \
                                                 --stl_input_white /output/white+brain_stem+cerebellum.union.surface.stl \
                                                 --max_iter 150 --edge_movement -0.5 --smoothing 0.5 \
                                                 --output_lh_pial /output/lh_pial.union.surface.stl \
                                                 --output_rh_pial /output/rh_pial.union.surface.stl 


docker exec svmtk python3 /utils/union_surface.py --stl_input_1 /output/lh_pial.union.surface.stl \
                                              --stl_input_2 /output/rh_pial.union.surface.stl \
                                              --output /output/pial.union.surface.stl


### adesso si costruisce la mesh .
RESOLUTION=32
docker exec svmtk python3 /utils/create_two_domain_tagged_mesh.py --stl_input_ext /output/pial.union.surface.stl \
                                            --stl_input_inn /output/white+brain_stem+cerebellum.union.surface.stl \
                                            --output /output/brain.$RESOLUTION.mesh -r $RESOLUTION

docker exec svmtk meshio convert /output/brain.$RESOLUTION.mesh /output/brain.$RESOLUTION.vtu

# con ventricoli
docker exec svmtk python3 /utils/create_three_domain_tagged_mesh.py -sip /output/pial.union.surface.stl \
                                            -siw /output/white+brain_stem+cerebellum.union.surface.stl \
                                            -siv /output/ventricles/ventricles_repaired.stl \
                                            --output /output/brain.with.ventricles.$RESOLUTION.mesh -r $RESOLUTION

docker exec svmtk meshio convert /output/brain.with.ventricles.$RESOLUTION.mesh /output/brain.with.ventricles.$RESOLUTION.vtu

