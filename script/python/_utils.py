import os, sys
import SVMTK as svm
import meshio
import pyvista as pv
import numpy as np
import nibabel as nib
import matplotlib.pyplot as plt
from matplotlib.tri import Triangulation
import progressbar
pv.set_jupyter_backend('client')
from pathlib import Path
from collections import Counter
from shapely import LineString, Polygon, simplify, LinearRing
from nilearn import plotting, image
from nilearn.image import mean_img

def make_slice(filename, outdir="results/", D = 0):
    Path(outdir).mkdir(exist_ok=True)   
    surf = svm.Surface(filename)
    
    # Create a cut plane 
    plane = svm.Plane_3(1,0,0,D) #15
    # Cut surface 
    slce = surf.get_slice(plane)
    # Creating a mesh
    slce.create_mesh(16.0) # migliorare con minimo angolo e max area ?!
    # Saves mesh with helping faces
    outfile = outdir + "compact.stl"
    slce.save(outfile)
    # Remove any helping faces

    outfile = outdir + "keep_all_components.stl"
    slce.add_surface_domains([surf])
    slce.save(outfile)    
    
    # Deletes smaller clusters of faces 
    slce.keep_largest_connected_component()
    outfile = outdir + "keep_largest_component.stl"
    slce.save(outfile)

def meshio2pyvista(mesh):
    points = mesh.points
    triangles = mesh.cells_dict["triangle"].astype(int)
    formatted_triangles = list()
    for elem in triangles:
        formatted_triangles.append([3, elem[0], elem[1], elem[2]])
    
    formatted_triangles = np.hstack(formatted_triangles)
    pv_mesh = pv.PolyData(points, formatted_triangles)
    return pv_mesh

def load_mesh(filename):
    mesh = meshio.read(filename)
    return meshio2pyvista(mesh)

def center_mesh(pv_mesh, filename_nifti):
    img = nib.load(filename_nifti)
    data = img.get_fdata()
    affine = img.affine
    img_zero = (data.shape[0]//2, data.shape[1]//2, data.shape[2]//2)
    img_zero = nib.affines.apply_affine(affine, img_zero)
    points = pv_mesh.points + img_zero
    return pv.PolyData(points, pv_mesh.faces) 

def extract_boundary(pv_mesh):
    boundary_edges = pv_mesh.extract_feature_edges(boundary_edges=True, manifold_edges=False)
    boundary_pts = boundary_edges.points
    node_counter = Counter(boundary_edges.lines.reshape(-1,3)[:,1])

    lines = boundary_edges.lines.reshape(-1,3)[:,[1,2]]
    n_points = boundary_pts.shape[0]
    adjacency_matrix = np.zeros((n_points, n_points), dtype=int)

    # Fill the adjacency matrix
    for edge in lines:
        i, j = edge
        adjacency_matrix[i, j] = 1

    idxs = np.linspace(0,boundary_pts.shape[0]-1,boundary_pts.shape[0]).astype(int)
    paths = []
    while len(idxs) != 0:
        start_point = idxs[0]
        path = [start_point]
        end_point = np.where(adjacency_matrix[:,start_point] == 1)[0][0]
        
        current_point = start_point
        while current_point != end_point:
            next_point = np.where(adjacency_matrix[current_point,:] == 1)[0][0]
            path.append(next_point)
            current_point = next_point
        path.append(start_point)
        paths.append(path)
        idxs = np.setdiff1d(idxs,path)

    return {"boundary_pts": boundary_pts, "paths": paths, "adjacency_matrix": adjacency_matrix}
