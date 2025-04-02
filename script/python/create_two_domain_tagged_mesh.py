import argparse
import SVMTK as svmtk 

def create_two_domain_tagged_mesh(ext_stl, inn_stl, output, resolution = 32, remove_inn = False):
    # Load the surfaces into SVM-Tk and combine in list
    ext  = svmtk.Surface(ext_stl)
    inn = svmtk.Surface(inn_stl)
    surfaces = [inn, ext]
    
    # Create a map for the subdomains with tags
    # 1 for in between inn and ext ("01")
    # 2 for inside inside inn (and inside ext) ("11")
    smap = svmtk.SubdomainMap()
    smap.add("01", 1)
    smap.add("11", 2)
    smap.add("10", 2)

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
    parser.add_argument("-sie", "--stl_input_ext", type=str, help="Input file: external surface")
    parser.add_argument("-sii", "--stl_input_inn", type=str, help="Input file: inner surface")    
    parser.add_argument("-o", "--output", type=str, help="Output file")
    parser.add_argument("-r","--resolution", type=int, default=32, help="Resolution")
    parser.add_argument("-rv","--remove_inn", type=bool, default=False, help="Remove inner volume")
    Z = parser.parse_args() 

    create_two_domain_tagged_mesh(Z.stl_input_ext, Z.stl_input_inn, Z.output, Z.resolution, Z.remove_inn)
