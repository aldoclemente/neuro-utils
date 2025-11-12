#!/bin/bash
utils=$(pwd)/../../../script/python
outdir=$(pwd)
echo $outdir
docker run --rm -v $utils/:/utils/ -v $outdir/:/output/ --name=svmtk -dit aldoclemente/svmtk

input=/output/mni152.simnibs.clean.stl

mkdir -p mesh

declare -a res=(8 16 32 64)
for r in "${res[@]}"; do
    output=/output/mesh/mesh.$r.mesh
    docker exec svmtk python3 /utils/create_volume_mesh.py -i $input -o $output -r $r 
done

for r in "${res[@]}"; do
    input=/output/mesh/mesh.$r.mesh
    output=/output/mesh/mesh.$r
    #docker exec svmtk meshio convert $input $output.vtu
    #docker exec svmtk meshio convert $input $output.xdmf
    docker exec svmtk meshio convert $input $output.msh --output-format gmsh22
done

docker exec svmtk chown -R 1000:1000 /output/
docker stop svmtk
