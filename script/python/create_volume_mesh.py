import argparse
import SVMTK as svmtk

def create_volume_mesh(stlfile, output, resolution=16):
    # Load input file
    surface = svmtk.Surface(stlfile)
    
    # Generate the volume mesh
    domain = svmtk.Domain(surface)
    domain.create_mesh(resolution)

    # Write the mesh to the output file
    domain.save(output)

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, help="STL input file")      
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("-r","--resolution", type=int, default=16, help="Resolution") 
    Z = parser.parse_args() 

    create_volume_mesh(Z.input, Z.output, Z.resolution)


