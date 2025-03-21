import argparse
import SVMTK as svmtk

def smoothen_surface(stl_input, output, n=1, eps=1.0, preserve_volume=True):
    # Load input STL file
    surface = svmtk.Surface(stl_input)

    # Smooth using Taubin smoothing
    # if volume should be preserved,
    # otherwise use Laplacian smoothing
    if preserve_volume:
        surface.smooth_taubin(n)
    else:
        surface.smooth_laplacian(eps, n)
        
    # Save smoothened STL surface
    surface.save(output)

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-si", "--stl_input", type=str, help="Input file")      
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("--n", type=int, default=1, help="L") 
    parser.add_argument("--eps", type=float, default=1.0, help="n")
    parser.add_argument("-pv","--preserve_volume", type=bool, default=True, help="Preserve volume") 
    Z = parser.parse_args() 

    smoothen_surface(Z.stl_input, Z.output, Z.n, Z.eps, Z.preserve_volume)