# Downloading and Processing Diffusion Data from the Human Connectome Project (HCP)

This repository contains bash scripts to download and preprocess diffusion MRI data from the [Human Connectome Project (HCP)](https://www.humanconnectome.org/) using [FSL](https://fsl.fmrib.ox.ac.uk/fsl/docs/#/). The scripts handle downloading specific datasets from AWS S3 and fitting diffusion models using FSL tools.

## Prerequisites

- **HCP Account**: Create an account on the [HCP database](https://db.humanconnectome.org/). Log in, click on "Amazon S3 Access Enable," and store your access key and secret access key.
- **AWS CLI**: For command-line access and data downloads, install and configure the [AWS Command Line Interface (CLI)](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html).
- **FSL**: Required to fit the DTI models.

## Usage 

Run the following command in a terminal:

```
	./diffusion_hcp_data.sh <num_subjects>
```

`<num_subjects>` indicates the number of subjects for which you want to download and process the data. `input_idxs.txt` contains the IDs of all 488 available subjects. For parallel processing, use `diffusion_hcp_data_parallel.sh`, which relies on GNU Parallel.  
	
## Miscellaneous

```
	#list objects in a directory
	aws s3 ls s3://hcp-openaccess/HCP/

	# download a specific file
	aws s3 cp s3://hcp-openaccess/HCP/100307/MNINonLinear/.../path-to-file 

	# download the whole directory (NO!)
	aws s3 sync s3://hcp-openaccess/HCP/100307/
	
	
	# info 
	wb_command -file-information /path-to-file
```


```
	# download task-based fMRI data from HCP in /path/to/dir/tfMRI_<task>_LR for the first n_subjects 
	./fMRI_hcp_data.sh -s n_subjects -o /path/to/dir
	
	# convert all the .nii files in /path/to/dir to .func.gii files exploiting wb_command
	# The output files are availble at /path/to/dir_gii/
	./nii2func.gii.sh -i /path/to/dir/
```
