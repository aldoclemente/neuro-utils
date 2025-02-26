import numpy as np
import nibabel as nib
import os
from pathlib import Path

import argparse
parser = argparse.ArgumentParser()

parser.add_argument('--data', help="input directory", type= str)
parser.add_argument('--bvals', help="input directory", type= str)
parser.add_argument('--bvecs', help="input directory", type= str)
args=parser.parse_args()


outdir = str(Path(args.data).parent.absolute()) + "/"

# Load b-values and b-vectors
bvals = np.loadtxt(args.bvals)
bvecs = np.loadtxt(args.bvecs)

# Sort indices based on b-values
sorted_indices = np.argsort(bvals)

# Reorder bvals and bvecs
bvals_sorted = bvals[sorted_indices]
bvecs_sorted = bvecs[:, sorted_indices]

# Save reordered gradient files
np.savetxt(outdir + "bvals", bvals_sorted, fmt="%d")
np.savetxt(outdir + "bvecs", bvecs_sorted, fmt="%.6f")

# Load NIfTI file and reorder volumes
img = nib.load(args.data)
data = img.get_fdata()
affine = img.affine

# Reorder diffusion volumes
data_sorted = data[..., sorted_indices]

# Save reordered NIfTI file
new_img = nib.Nifti1Image(data_sorted, affine)
nib.save(new_img, outdir + "data.nii.gz")

print("Reordering complete!")

