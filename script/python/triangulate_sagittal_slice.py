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
					default= "/home/aldoclemente/Documents/aldo/aldo/100307/T1w/Diffusion/FSL/FSL_tensor_MNI152.nii.gz")
parser.add_argument('--tolerance', help="tolerance for the simplification algorithm", type= float, 
					default= 0.2)
parser.add_argument('--max_area', help="maximum element area", type= float, 
					default= 1.)
parser.add_argument('--min_angle', help="minimum element angle", type= float, 
					default= 30)
parser.add_argument('--outdir', help="output directory (end with '/'!!!)", type= str, 
					default= "./")


args=parser.parse_args()
outdir = args.outdir + "brain_slices/"
Path(outdir).mkdir(exist_ok=True)
outdir = outdir + args.template + "/"
Path(outdir).mkdir(exist_ok=True)

inputpial = "../../data/" + args.template + "/"
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
        
pv_mesh_not_centered = load_mesh(preproc_dir+"slice_repaired_self_intersection.stl")
pv_mesh = center_mesh(pv_mesh_not_centered, args.nifti)

fine_dir = outdir + "fine/"
if(not Path(fine_dir).exists()):
	Path(fine_dir).mkdir(exist_ok=True)
	np.savetxt(fine_dir + "points.txt", pv_mesh.points[:,[1,2]])
	np.savetxt(fine_dir + "triangles.txt", pv_mesh.faces.reshape(-1,4)[:,[1,2,3]])
	
	voxel_indices = np.array(list(np.ndindex(data.shape[0:3])))
	voxel_centers = nib.affines.apply_affine(affine, voxel_indices)
	mask = []
	
	result = np.zeros((voxel_indices.shape[0], data.shape[len(data.shape)-1]))
	bar = progressbar.ProgressBar(max_value=(voxel_centers.shape[0]-1))
	for i in range(0,voxel_centers.shape[0]):
		result[i,] = data[tuple(voxel_indices[i,])]
		if pv_mesh.find_containing_cell(voxel_centers[i,]) >=0: # !=-1
		    mask.append(i)
		bar.update(i)

	np.savetxt(fine_dir + "voxel_centers.txt", voxel_centers)
	np.savetxt(fine_dir + "voxel_centers_mask.txt", mask)
	np.savetxt(fine_dir + "data.txt", result)

# ---- comune anche a save data ?! 

boundary = extract_boundary(pv_mesh)
boundary_pts = boundary["boundary_pts"]
paths = boundary["paths"]

rings = []
for i in range(0,len(paths)):
    rings.append(LineString(boundary_pts[paths[i]][:, 1:3]))

holes = [] 
if(len(paths) > 1):
    for i in range(1,len(paths)):
        holes.append(rings[i])

poly = Polygon(rings[0], holes=holes)

# arg ?! -------------
#tol = 0.2

poly_simp = poly.simplify(tolerance=args.tolerance, preserve_topology=True)
x_ = []
y_ = []
bd_pts = []
x_.append(poly_simp.exterior.xy[0])
y_.append(poly_simp.exterior.xy[1])

for i in range(len(paths)-1):
    x_.append(poly_simp.interiors[i].xy[0])
    y_.append(poly_simp.interiors[i].xy[1])

for i in range(len(paths)):
    bd_pts.append( np.zeros((len(x_[i]), 3)) )
    bd_pts[i][:,0] = -cut*np.ones(len(x_[i])) # NOTE the minus            
    bd_pts[i][:,1] = x_[i]
    bd_pts[i][:,2] = y_[i]

meshdir = outdir + "simplified_" + str(args.tolerance) + "/"
Path(meshdir).mkdir(exist_ok=True)  

for i in range(0,len(bd_pts)):
    np.savetxt(meshdir + "points_ring_" + str(i) + ".txt" , 
               bd_pts[i][0:(bd_pts[i].shape[0]-1),1:3]) # remove last (first...) point
               
# args ?!
#maximum_area = 5
# args ?!
#minimum_angle = 30
os.system("Rscript ../R/triangulate_boundary.R " + meshdir + " " + 
                                             str(args.max_area) + " " + 
                                             str(args.min_angle))
