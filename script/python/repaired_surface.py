import argparse
import SVMTK as svmtk

def repaired_surface(stl_input, output, adjustment, smoothing, maxiter):
    # Import the STL surface
    surface = svmtk.Surface(stl_input) 

    # Find and fill holes 
    surface.fill_holes()

    # Separate narrow gaps
    # Default argument is -0.33. 
    #surface.separate_narrow_gaps(adjustment), 0.0, 150)
    surface.separate_narrow_gaps(adjustment, smoothing, maxiter)   
    # Save repaired STL surface
    surface.save(output)


if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-si", "--stl_input", type=str, help="Input file")      
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("--adjustment", type=float, help="adjustment", default=-0.25)
    parser.add_argument("--smoothing", type=float, help="smoothing", default=0.)
    parser.add_argument("--maxiter", type=int, help="max iterations", default=100)
    Z = parser.parse_args() 

    repaired_surface(Z.stl_input, Z.output, Z.adjustment, Z.smoothing, Z.maxiter)
