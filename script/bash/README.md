```
	# download task-based fMRI data from HCP in /path/to/dir/tfMRI_EMOTIONAL_LR for the first n_subjects 
	./fMRI_hcp_data.sh -s n_subjects -o /path/to/dir
	
	# convert all the .nii files in /path/to/dir to .func.gii files exploiting wb_command
	# The output files are availble at /path/to/dir_gii/
	./nii2func.gii.sh -i /path/to/dir/
```
