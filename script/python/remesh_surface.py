import argparse
import SVMTK as svmtk

def remesh_surface(stl_input, output, L, n, do_not_move_boundary_edges=False):

    # Load input STL file
    surface = svmtk.Surface(stl_input)

    # Remesh surface
    surface.isotropic_remeshing(L, n, do_not_move_boundary_edges)

    # Save remeshed STL surface 
    surface.save(output)

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-si", "--stl_input", type=str, help="Input file")      
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("--L", type=float, default=1.0, help="L") 
    parser.add_argument("--n", type=int, default=3, help="n") 
    parser.add_argument("-nmbe","--do_not_move_boundary_edges", type=bool, default=False, help="Do not move boundary edges") 
    Z = parser.parse_args() 

    remesh_surface(Z.stl_input, Z.output, Z.L , Z.n, Z.do_not_move_boundary_edges) 
