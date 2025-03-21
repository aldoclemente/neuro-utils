#!bin/bash

# $1 input stl file 

OUTDIR="$(dirname -- "$(realpath -- "$1")")"
BNAME=$(basename "$1" .stl)
RAW=$BNAME.stl
REMESH=${BNAME}_remesh.stl 
SMOOTH=${BNAME}_smooth.stl 
REPAIR=${BNAME}_repaired.stl 
OUTMESH=${BNAME}.mesh
OUTVIEW=${BNAME}.xdmf 

UTILS=$HOME/neuro-utils/script/python
APPTAINER=/opt/mox/apptainer/bin/apptainer
IMG=$HOME/fsl_latest.sif

$APPTAINER exec $IMG python3 /utils/remesh_surface.py --stl_input $OUTDIR/$RAW --output $OUTDIR/$REMESH
$APPTAINER exec $IMG python3 $UTILS/smoothen_surface.py --stl_input $OUTDIR/$RAW --output $OUTDIR/$SMOOTH --n 10
$APPTAINER exec $IMG python3 $UTILS/repaired_surface.py --stl_input $OUTDIR/$SMOOTH --output $OUTDIR/$REPAIR
$APPTAINER exec $IMG python3 $UTILS/create_volume_mesh.py --stl_input $OUTDIR/$REPAIR --output $OUTDIR/$OUTMESH
$APPTAINER exec $IMG meshio-convert $OUTDIR/$OUTMESH $OUTDIR/$OUTVIEW

