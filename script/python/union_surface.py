import argparse
import SVMTK as svmtk

def union_surfaces(surf1_stl, surf2_stl, adjust, output):

    # Create SVMTk Surfaces from STL files
    surf1 = svmtk.Surface(surf1_stl)
    surf2 = svmtk.Surface(surf2_stl)
    
    #surf = svmtk.union_partially_overlapping_surfaces(surf1, surf2, adjustment=adjust)
    surf1.union(surf2)
    surf1.save(output)
    
    
if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--stl_input_1", type=str, help="Input file 1")
    parser.add_argument("--stl_input_2", type=str, help="Input file 2")
    parser.add_argument("--adjustment", type=float, help="adj", default=2.0)
    parser.add_argument("-o", "--output", type=str, help="Output file")
    
    Z = parser.parse_args() 

    union_surfaces(Z.stl_input_1, Z.stl_input_2, Z.adjustment, Z.output)
