import argparse
import SVMTK as svmtk

def create_three_domain_tagged_mesh(pial_stl, white_stl, ventricles_stl, output, resolution=32, remove_ventricles=False):

    # Create SVMTk Surfaces from STL files
    pial  = svmtk.Surface(pial_stl)
    white = svmtk.Surface(white_stl)
    ventricles = svmtk.Surface(ventricles_stl)
    surfaces = [pial, white, ventricles]

    # Define identifying tags for the different regions 
    tags = {"pial": 1, "white": 2, "ventricle": 3}

    # Define the corresponding subdomain map
    smap = svmtk.SubdomainMap()
    smap.add("100", tags["pial"])
    smap.add("110", tags["white"])
    smap.add("010", tags["white"])
    smap.add("111", tags["ventricle"])
    
    # Mesh and tag the domain from the surfaces and map
    domain = svmtk.Domain(surfaces, smap)
    domain.create_mesh(resolution)
    
    # Remove subdomain with right tag from the domain
    if remove_ventricles:
        domain.remove_subdomain(tags["ventricle"])
        
    # Save the mesh  
    domain.save(output) 

if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-sip", "--stl_input_p", type=str, help="Input file: pial surface")
    parser.add_argument("-siw", "--stl_input_w", type=str, help="Input file: white surface")
    parser.add_argument("-siv", "--stl_input_v", type=str, help="Input file: ventricles surface")    
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("-r","--resolution", type=int, default=32, help="Resolution")
    parser.add_argument("-rv","--remove_ventricles", type=bool, default=False, help="Remove ventricles")

    Z = parser.parse_args() 

    create_three_domain_tagged_mesh(Z.stl_input_p, Z.stl_input_w, Z.stl_input_v, Z.output, Z.resolution, Z.remove_ventricles)
