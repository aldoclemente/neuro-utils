### FSL - Get started

Pull the docker image: 
```
docker pull aldoclemente/fsl
```

Run a container with mounted input directory:
```
docker run --rm --name=fsl -v /path/to/input/:/input/ -dit aldoclemente/fsl 
```
*Notes*
- `/path/to/input/` is the local directory containing your inputs
- The `--rm` flag ensures the container is automatically removed after stopping.
- The `-dit` flags allow you to properly run the container. Specifically, it let you run the container in detached mode while keeping it interactive and allocating a pseudo-TTY


You can run fsl commands, such as bet, as follows: 
```
docker exec fsl bet -h
```
Once finished, remember to stop your container. If you did not use the `--rm` flag, you may need to remove it manually:
```
docker stop fsl 
```

#### Running on apptainer (formerly, singularity)

Pull the image as follows:
```
/path/to/apptainer pull docker://aldoclemente/fsl
```
Run `fsl` commands using `exec`, for instance:
```
/path/to/apptainer exec /path/to/fsl_latest.sif bet -h
```

### SVMTK - Get started
Pull the docker image: 
```
docker pull aldoclemente/svmtk
```

Build a 3d mesh starting from a stl file:
```
UTILS=/path/to/neuro-utils/script/python
INPUT=/path/to/input.stl

OUTDIR="$(dirname -- "$(realpath -- "$INPUT")")"
BNAME=$(basename "$INPUT" .stl)
RAW=$BNAME.stl
REMESH=${BNAME}_remesh.stl 
SMOOTH=${BNAME}_smooth.stl 
REPAIR=${BNAME}_repaired.stl 
OUTMESH=${BNAME}.mesh
OUTVIEW=${BNAME}.xdmf

docker run --rm -v $UTILS/:/utils/ -v $OUTDIR:/output/ --name=svmtk -dit aldoclemente/svmtk

docker exec svmtk python3 /utils/smoothen_surface.py --stl_input /output/$RAW --output /output/$SMOOTH --n 10
docker exec svmtk python3 /utils/repaired_surface.py --stl_input /output/$SMOOTH --output /output/$REPAIR
docker exec svmtk python3 /utils/create_volume_mesh.py --stl_input /output/$REPAIR --output /output/$OUTMESH
docker exec svmtk meshio convert /output/$OUTMESH /output/$OUTVIEW
docker stop svmtk
```
