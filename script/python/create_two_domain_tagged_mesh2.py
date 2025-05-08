import argparse
import SVMTK as svmtk 

def create_two_domain_tagged_mesh2(lh_pial_stl, rh_pial_stl, white_stl, 
                                   output, resolution = 32, remove_inn = False):
    # Load the surfaces into SVM-Tk and combine in list
    
    lh_pial  = svmtk.Surface(lh_pial_stl)
    rh_pial  = svmtk.Surface(rh_pial_stl)
    white = svmtk.Surface(white_stl)
    
    surfaces = [white, lh_pial, rh_pial]
    
    svmtk.separate_overlapping_surfaces(lh_pial, rh_pial, white)
    svmtk.separate_close_surfaces(lh_pial, rh_pial, white)
    
    # Define identifying tags for the different regions 
    tags = {"pial": 1, "white": 2}

    # Create a map for the subdomains with tags
    # 1 for in between inn and ext ("01")
    # 2 for inside inside inn (and inside ext) ("11")
    smap = svmtk.SubdomainMap()
    smap.add("010", 1)
    smap.add("001", 1)
    smap.add("110", 2)
    smap.add("101", 2)
    smap.add("111", 1)
    

    # Create a tagged domain from the list of surfaces
    # and the map
    domain = svmtk.Domain(surfaces, smap)
       
    # Create and save the volume mesh 
    domain.create_mesh(resolution)

    if remove_inn:
        domain.remove_subdomain(2)

    domain.save(output) 

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-silp", "--stl_input_lh_p", type=str, help="Input file: left pial surface")
    parser.add_argument("-sirp", "--stl_input_rh_p", type=str, help="Input file: right pial surface")
    parser.add_argument("-siw", "--stl_input_w", type=str, help="Input file: white (+ non cortical) surface")    
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("-r","--resolution", type=int, default=32, help="Resolution")
    parser.add_argument("-rv","--remove_inn", type=bool, default=False, help="Remove inner volume")
    Z = parser.parse_args() 

    create_two_domain_tagged_mesh2(Z.stl_input_lh_p, Z.stl_input_rh_p, Z.stl_input_w, 
                                  Z.output, Z.resolution, Z.remove_inn)
