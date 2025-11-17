import argparse
import numpy as np
import meshio


def write_vector_to_mtx(filename, vector, comment="from_volume nodal values"):
    """
    Write a 1D numpy array to a Matrix Market .mtx file
    in coordinate format as an N x 1 dense vector.
    """
    vector = np.asarray(vector).reshape(-1)
    n = vector.size

    with open(filename, "w") as f:
        # Matrix Market header
        f.write("%%MatrixMarket matrix coordinate real general\n")
        # matrix dimensions and number of nonzeros
        # (N rows, 1 column, N nonzeros for a dense vector)
        f.write(f"{n} 1 {n}\n")

        # Data: i j value (1-based indices)
        for i, val in enumerate(vector, start=1):
            f.write(f"{i} 1 {float(val):.16g}\n")


def vtu2mtx(input_vtu, output_mtx):

    # Read mesh
    mesh = meshio.read(input_vtu)

    # Expect 'from_volume' to be a point_data field
    if "from_volume" not in mesh.point_data:
        print("Error: 'from_volume' not found in mesh.point_data.")
        print("Available point_data keys:", list(mesh.point_data.keys()))
        sys.exit(1)

    data = mesh.point_data["from_volume"]

    # Handle multi-component data (e.g., vectors); use first component or adapt as you wish
    if data.ndim == 2 and data.shape[1] > 1:
        print(
            "Warning: 'from_volume' appears to be multi-component "
            f"({data.shape[1]} components). Using the first component only."
        )
        data = data[:, 0]

    write_vector_to_mtx(output_mtx, data, comment="from_volume nodal values")

    print(f"Written {data.size} nodal values to '{output_mtx}' in Matrix Market format.")


if __name__ =='__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("-i", "--input", type=str, help="vtu input file")      
    parser.add_argument("-o", "--output", type=str, help="mtx output file")
    Z = parser.parse_args() 

    vtu2mtx(Z.input, Z.output)
