#!/bin/bash    

INPUT=$1
UTILS=$(pwd)/../python #$HOME/Desktop/neuro-utils/script/python
BNAME=$(basename "$INPUT" .stl)
INDIR="$(dirname -- "$(realpath -- "$INPUT")")"
#OUTDIR="$(dirname -- "$(realpath -- "$INPUT")")"/$BNAME

#if ! [ -d OUTDIR ]; then mkdir -p $OUTDIR; fi

RAW=$BNAME.stl
REMESH=${BNAME}_remesh.stl 
SMOOTH=${BNAME}_smooth.stl
REPAIR=${BNAME}_repaired.stl

#docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ -v $INDIR/:/input/ --name=svmtk -dit aldoclemente/svmtk
docker run --rm -v $UTILS/:/utils/ -v $INDIR/:/output/ --name=svmtk -dit aldoclemente/svmtk

echo " --- remesh surface --- "
#docker exec svmtk python3 /utils/remesh_surface.py --stl_input /input/$RAW --output /output/$REMESH #--L 1.0 --n 3
docker exec svmtk python3 /utils/remesh_surface.py --stl_input /output/$RAW --output /output/$REMESH #--L 1.0 --n 3
   
echo " --- smooth surface --- "
docker exec svmtk python3 /utils/smoothen_surface.py --stl_input /output/$REMESH --output /output/$SMOOTH #--n 10

echo " --- repair surface --- "
docker exec svmtk python3 /utils/repaired_surface.py --stl_input /output/$SMOOTH --output /output/$REPAIR
 
docker stop svmtk

#docker run --rm -v $FREESURFER/license.txt:/usr/local/freesurfer/license.txt -v $OUTDIR/:/input/ freesurfer/freesurfer:7.4.1 mris_info /input/$REPAIR


#docker run --rm -v $UTILS/:/utils/ -v $OUTDIR/:/output/ -v $INDIR/:/input/ --name=svmtk -dit aldoclemente/svmtk

#echo " --- remesh surface --- "
#docker exec svmtk python3 /utils/remesh_surface.py --stl_input /input/$RAW --output /output/$REMESH #--L 1.0 --n 3
  
#echo " --- smooth surface --- "
#docker exec svmtk python3 /utils/smoothen_surface.py --stl_input /output/$REMESH --output /output/$SMOOTH #--n 10

#echo " --- repair surface --- "
#docker exec svmtk python3 /utils/repaired_surface.py --stl_input /output/$SMOOTH --output /output/$REPAIR
 
#docker stop svmtk

#docker run --rm -v $FREESURFER/license.txt:/usr/local/freesurfer/license.txt -v $OUTDIR/:/input/ freesurfer/freesurfer:7.4.1 mris_info /input/$REPAIR
