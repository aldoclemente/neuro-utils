import argparse
import SVMTK as svmtk

def repaired_surface(stl_input, output):
    # Import the STL surface
    surface = svmtk.Surface(stl_input) 

    # Find and fill holes 
    surface.fill_holes()

    # Separate narrow gaps
    # Default argument is -0.33. 
    surface.separate_narrow_gaps(-0.25)
        
    # Save repaired STL surface
    surface.save(output)


if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-si", "--stl_input", type=str, help="Input file")      
    parser.add_argument("-o", "--output", type=str, help="Output file")
    Z = parser.parse_args() 

    repaired_surface(Z.stl_input, Z.output)