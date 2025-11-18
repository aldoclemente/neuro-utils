import argparse
import numpy as np
import meshio

def mtx2vtu(input_vtu, input_mtx, output_vtu):

    # Read mesh
    mesh = meshio.read(input_vtu)
    coeffs = np.loadtxt(input_mtx, skiprows=2) # skip the header lines
    mesh.point_data["estimate"] = coeffs[:,2] # third column has the values
    meshio.write(output_vtu, mesh)

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, help="vtu input file")      
    parser.add_argument("-m", "--mtx", type=str, help="mtx input file")
    parser.add_argument("-o", "--output", type=str, help="vtu output file")
    Z = parser.parse_args() 

    mtx2vtu(Z.input, Z.mtx ,Z.output)
