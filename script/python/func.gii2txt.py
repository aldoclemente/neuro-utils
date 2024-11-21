from _utils import *
from pathlib import Path
import argparse
import nibabel as nib
import numpy as np

parser = argparse.ArgumentParser()
parser.add_argument('--inputdir', help="input directory", type= str)
args=parser.parse_args()
inputdir = str(Path(args.inputdir).resolve()) + "/"
outdir = inputdir + "as_txt/"
Path(outdir).mkdir(exist_ok=True)

for r, d, f in os.walk(inputdir):
	for cifti in f:
		if cifti.endswith("func.gii"):
			gii = nib.load(inputdir + cifti)
			img_data = [x.data for x in gii.darrays]
			result = np.zeros((img_data[0].shape[0], len(img_data)))
			for j in range(0, len(img_data)):
				result[:,j] = img_data[j]
			np.savetxt(outdir + cifti.split(".func.gii")[0] + ".txt", result) 
