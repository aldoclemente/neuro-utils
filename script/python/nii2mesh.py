import argparse
import numpy as np
import nibabel as nib
import meshio
from scipy.ndimage import map_coordinates

def nii2mesh(nifti_path, mesh_path, output_path,
    method="linear",  # "linear" or "nearest"
):
  
    # Load NIfTI
    img = nib.load(nifti_path)
    data = img.get_fdata()  # shape (256, 256, 256)
    affine = img.affine

    mesh = meshio.read(mesh_path)
    mesh_nodes = mesh.points

    # world (x,y,z) -> voxel (i,j,k)
    inv_affine = np.linalg.inv(affine)
    # nibabel has helper, but we can do homogeneous multiplication directly:
    homog = np.c_[mesh_nodes, np.ones(mesh_nodes.shape[0])]
    vox_coords = homog @ inv_affine.T
    vox_coords = vox_coords[:, :3]  # keep (i,j,k)
    
    # 2) Prepare coordinates for map_coordinates (shape (3, M))
    coords = np.vstack([
        vox_coords[:, 0],  # i
        vox_coords[:, 1],  # j
        vox_coords[:, 2],  # k
    ])

    # 3) Choose interpolation order
    if method == "nearest":
        order = 0
    elif method == "linear":
        order = 1
    else:
        raise ValueError("method must be 'linear' or 'nearest'")

    # 4) Interpolate
    # mode='nearest' avoids extrapolation weirdness at the borders
    node_values = map_coordinates(
        data,
        coords,
        order=order,
        mode="nearest",
    )

    mesh.point_data["from_volume"] = node_values.astype(np.float32)
    meshio.write(output_path, mesh)

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, help="nifit input file")
    parser.add_argument("-vtu", "--input_vtu", type=str, help="vtu input file")      
    parser.add_argument("-o", "--output", type=str, help="vtu output file")
    parser.add_argument("-m", "--method", type=str, help="interpolation method: linear or nearest", default="linear")
    Z = parser.parse_args() 

    
    nii2mesh(Z.input, Z.input_vtu, Z.output, Z.method)
