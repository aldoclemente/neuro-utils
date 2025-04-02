import argparse
import SVMTK as svmtk

def merge_hemispheres2(lh_pial_stl, rh_pial_stl, white_stl,
                      edge_movement, smoothing, max_iter, 
                      output_lh_pial, output_rh_pial):

    # Create SVMTk Surfaces from STL files
    lh_pial = svmtk.Surface(lh_pial_stl)
    rh_pial = svmtk.Surface(rh_pial_stl)
    white = svmtk.Surface(white_stl)
   
    svmtk.separate_overlapping_surfaces(lh_pial, rh_pial, white, edge_movement, smoothing, max_iter)
    svmtk.separate_close_surfaces(lh_pial, rh_pial, white, edge_movement, smoothing, max_iter)
    lh_pial.save(output_lh_pial)
    rh_pial.save(output_rh_pial)
    
if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--stl_input_lh_pial", type=str, help="Input file: left pial surface")
    parser.add_argument("--stl_input_rh_pial", type=str, help="Input file: right pial surface")
    parser.add_argument("--stl_input_white", type=str, help="Input file: white surface (or white+brain_stem+cerebellum") # !!!
    parser.add_argument("--edge_movement", type=float, help="edge movement", default=-0.4)
    parser.add_argument("--smoothing", type=float, help="smoothing", default=0.4)
    parser.add_argument("--max_iter", type=int, help="max iterations", default=50)    
    parser.add_argument("--output_lh_pial", type=str, help="Output file")
    parser.add_argument("--output_rh_pial", type=str, help="Output file")
    #parser.add_argument("--output_white", type=str, help="Output file")
    
    Z = parser.parse_args() 

    merge_hemispheres2(Z.stl_input_lh_pial, Z.stl_input_rh_pial, Z.stl_input_white, 
                      Z.edge_movement , Z.smoothing, Z.max_iter, 
                      Z.output_lh_pial, Z.output_rh_pial)
