#!bin/bash

# $1 input stl file 

OUTDIR="$(dirname -- "$(realpath -- "$1")")"
REMESH=$(basename "$1")_remesh.stl 
SMOOTH=$(basename "$1")_smooth.stl 
REPAIR=$(basename "$1")_repaired.stl 
OUTMESH=$(basename "$1").mesh
OUTVIEW=$(basename "$1").xdmf 

UTILS=$HOME/neuro-utils/script/python
APPTAINER=/opt/mox/apptainer/bin/apptainer


$APPTAINER exec -B $OUTDIR/:/output/ -B $UTILS:/utils/ python3 /utils/remesh_surface.py \ 
					--stl_input /output/$INPUTSTL --output /output/$REMESH
$APPTAINER exec -B $OUTDIR/:/output/ -B $UTILS:/utils/ python3 /utils/smoothen_surface.py \
				   --stl_input /output/$REMESH --output /output/$SMOOTH --n 10
$APPTAINER exec -B $OUTDIR/:/output/ -B $UTILS:/utils/ python3 /utils/repaired_surface.py \ 
				   --stl_input /output/$SMOOTH --output /output/$REPAIR
$APPTAINER exec -B $OUTDIR/:/output/ -B $UTILS:/utils/ python3 /utils/create_volume_mesh \ 
				   --stl_input /output/$REPAIR --output /output/$OUTPUT
$APPTAINER exec -B $OUTDIR/:/output/ -B $UTILS:/utils/ meshio-convert /output/$OUTPUT /output/$OUTVIEW


