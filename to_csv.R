library(RNifti)

## read arguments from command line
args <- commandArgs(trailingOnly = TRUE)

subject <- args[1]
print("R")
print(subject)


## load the nifti file
path_data <-  paste("Diffusion/", subject, "/acpc_dc2standard/", sep = "")
tensor_data <- readNifti(paste(path_data, "dti_tensor.nii", sep = ""))
tensor_array <- as.array(tensor_data)

# reshape the 4D tensor array into a 2D matrix where each row is a voxel and each column is a tensor component
slice <- tensor_array[54,,,]
voxel_df <- t(as.data.frame(apply(slice, c(2, 1), c)))

# assign meaningful column names
colnames(voxel_df) <- c("Dxx", "Dyy", "Dzz", "Dxy", "Dxz", "Dyz")

write.table(voxel_df, paste("tensors/tensor_", subject,".txt", sep = ""), row.names = FALSE, col.names = FALSE)
