import numpy as np
import nibabel as nib
import os
from collections import Counter
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

# Load NIfTI file and reorder volumes
img = nib.load(args.data)
data = img.get_fdata()
affine = img.affine

# Reorder diffusion volumes
data_sorted = data[..., sorted_indices]

# FILTER
# Set minimum number of volumes per shell
MIN_SHELL_SIZE = 10  # Adjust this threshold as needed

# Count occurrences of each b-value
bval_counts = Counter(bvals_sorted)

# Identify shells to keep
valid_shells = {b for b, count in bval_counts.items() if count >= MIN_SHELL_SIZE}

# Get indices of volumes to keep
keep_indices = np.array([i for i, b in enumerate(bvals_sorted) if b in valid_shells])

# store...
bvals_filtered = bvals_sorted[keep_indices]
bvecs_filtered = bvecs_sorted[:, keep_indices]

np.savetxt(outdir + "bvals", bvals_filtered, fmt="%d")
np.savetxt(outdir + "bvecs", bvecs_filtered, fmt="%.6f")

# Save reordered NIfTI file
data_filtered = data_sorted[..., keep_indices]
new_img = nib.Nifti1Image(data_filtered, affine)
nib.save(new_img, outdir + "data.nii.gz")

print("Reordering & filtering complete!")

