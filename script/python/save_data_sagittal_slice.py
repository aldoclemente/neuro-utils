from _utils import *
import argparse

parser = argparse.ArgumentParser()
parser.add_argument('--template', help="reference template", type= str, 
					default = "MNI152_2mm")
parser.add_argument('--hemi', help="hemisfere", type= str, 
					default= "lh")
parser.add_argument('--voxel_coord', help="sagittal (x) voxel coordinates", type= int, 
					default = 53)
parser.add_argument('--nifti', help="nifti image used to center the mesh", type= str, 
					default= "100307/T1w/Diffusion/FSL/FSL_tensor_MNI152.nii.gz")

args=parser.parse_args()

Path("results/").mkdir(exist_ok=True)
outdir = "results/" + args.template + "/"
Path(outdir).mkdir(exist_ok=True)

inputpial = "data/" + args.template + "/"
inputpial += args.hemi + ".pial.stl"
    
img = nib.load(args.nifti).slicer[args.voxel_coord:(args.voxel_coord+1), ...]                 
data = img.get_fdata()
header = img.header
affine = img.affine # mappa vox2ras

cut = nib.affines.apply_affine(affine, (0, 0, 0))[0]
outdir += "sagittal_slice_" + str(args.voxel_coord) + "/"

Path(outdir).mkdir(exist_ok=True)
preproc_dir = outdir + "preproc/"

if(not Path(preproc_dir).exists()):
    Path(preproc_dir).mkdir(exist_ok=True)
    make_slice(inputpial, preproc_dir, -cut) # NOTE the "minus"
    slice = svm.Surface(preproc_dir+"keep_largest_component.stl")
    if slice.num_self_intersections() > 0:
        print("Start: number of self intersections", slice.num_self_intersections())
        volume_threshold = 0.01 
        cap_threshold = 160
        needle_threshold = 3.0
        collapse_threshold = 0.2
        slice.repair_self_intersections(volume_threshold, cap_threshold, needle_threshold, collapse_threshold)
        print("End: number of self intersections", slice.num_self_intersections())
        slice.save(preproc_dir + "slice_repaired_self_intersection.stl")
    else:
        slice.save(preproc_dir + "slice_repaired_self_intersection.stl")

