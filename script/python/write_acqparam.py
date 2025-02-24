
import json
from pathlib import Path
import argparse
import math
import os

parser = argparse.ArgumentParser()
parser.add_argument('--input', help="input json file", type= str)
args=parser.parse_args()

# Open and read the JSON file
with open(args.input, 'r') as file:
    data = json.load(file)

# Print the data
# print(data)

#output = open("acqparam.txt"
output_params = str(Path(args.input).parent.absolute()) + "/acqparams.txt"

# Extract values
phase_encoding = data.get("PhaseEncodingDirection", None)
total_readout_time = data.get("TotalReadoutTime", None)
manufacturer = data.get("Manufacturer", "").lower()
polarity_flipped = data.get("PhaseEncodingPolarityGE", "Normal") == "Flipped"

# Check if required fields exist
if not phase_encoding or total_readout_time is None:
    raise ValueError("Missing PhaseEncodingDirection or TotalReadoutTime in JSON.")


if not total_readout_time is None:
	total_readout_time = round(total_readout_time, 3)

# Determine phase encoding for FSL
encoding_map = {
    "i": "1 0 0",
    "i-": "-1 0 0",
    "j": "0 1 0",
    "j-": "0 -1 0",
    "k": "0 0 1",
    "k-": "0 0 -1",
}

if phase_encoding in encoding_map:
    acqp_line = encoding_map[phase_encoding]
else:
    raise ValueError(f"Unknown PhaseEncodingDirection: {phase_encoding}")

# Adjust for GE scanners with flipped polarity
if manufacturer == "ge" and polarity_flipped:
    acqp_values = list(map(int, acqp_line.split()))
    acqp_values[1] *= -1  # Flip the phase encoding direction
    acqp_line = " ".join(map(str, acqp_values))

acqp_line += f" {total_readout_time}"

with open(output_params, "w") as f:
    f.write(acqp_line + "\n")

