#!bin/bash

#PBS -S /bin/bash
#PBS -l nodes=1:ppn=96
#PBS -l walltime=48:00:00
#PBS -j oe
#PBS -N remesh

./create_mesh.sh $HOME/brain_mesh/BRAIN.stl
