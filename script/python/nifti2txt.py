from _utils import *
from pathlib import Path

import argparse
parser = argparse.ArgumentParser()

parser.add_argument('--inputdir', help="input directory", type= str)

args=parser.parse_args()

inputdir = str(Path(args.inputdir).resolve()) + "/"

for r, d, f in os.walk(inputdir):
	for nifti in f:
		if nifti.endswith(".nii.gz"):
			img = nib.load(inputdir + nifti)
			data = img.get_fdata()
			voxel_indices = np.array(list(np.ndindex(data.shape[0:3])))
			if len(data.shape) == 3:
				result = np.zeros((voxel_indices.shape[0], 1))
			else:
				result = np.zeros((voxel_indices.shape[0], data.shape[len(data.shape)-1]))
			for i in range(0,voxel_indices.shape[0]):
				result[i,] = data[tuple(voxel_indices[i,])]
				
			np.savetxt(inputdir + nifti.split(".nii.gz")[0] + ".txt", result)


