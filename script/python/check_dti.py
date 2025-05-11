import argparse
import numpy as np
import nibabel as nib

from nibabel.processing import resample_from_to 
np.seterr(divide='ignore', invalid='ignore') # dividing by 0 or NaN does not throw a run through time error   

def check_dti_data(dti_file, mask_file):
   # Load the DTI image data and mask:
   dti_image = nib.load(dti_file)
   dti_data = dti_image.get_fdata() 
   
   mask_image = nib.load(mask_file)
   mask = mask_image.get_fdata().astype(bool) 

   # Examine the differences in shape
   print("dti shape  ", dti_data.shape)
   print("mask shape ", mask.shape)
   M1, M2, M3 = mask.shape
   
   # Create an empty image as a helper for mapping
   # from DTI voxel space to T1 voxel space: 
   #shape = numpy.zeros((M1, M2, M3, 9)) 
   #vox2ras = mask_image.header.get_vox2ras()
   #Nii = nib.nifti1.Nifti1Image
   #helper = Nii(shape, vox2ras)
   
   # Resample the DTI data in the T1 voxel space: 
   #image = resample_from_to(dti_image, helper, order=0) 
   #D = image.get_fdata() 
   #print("resampled image shape ", D.shape)
   
   def reconstruct_tensor(D):
    """
    Reconstructs a full 3x3 symmetric tensor from 6 unique components.
    
    Parameters:
    - D: numpy array of shape (..., 6), where last dimension holds
         [Dxx, Dxy, Dxz, Dyy, Dyz, Dzz]
    
    Returns:
    - full_tensor: numpy array of shape (..., 3, 3)
    """
    Dxx, Dxy, Dxz, Dyy, Dyz, Dzz = D[..., 0], D[..., 1], D[..., 2], D[..., 3], D[..., 4], D[..., 5]
    
    full_tensor = np.zeros(D.shape[:-1] + (3, 3))
    full_tensor[..., 0, 0] = Dxx
    full_tensor[..., 1, 1] = Dyy
    full_tensor[..., 2, 2] = Dzz
    full_tensor[..., 0, 1] = full_tensor[..., 1, 0] = Dxy
    full_tensor[..., 0, 2] = full_tensor[..., 2, 0] = Dxz
    full_tensor[..., 1, 2] = full_tensor[..., 2, 1] = Dyz
    
    return full_tensor
   
   D = reconstruct_tensor(dti_data)
   print("reconstructed image shape ", D.shape)
   
   # Reshape D from M1 x M2 x M3 x 9 into a N x 3 x 3:
   D = D.reshape(-1, 3, 3)
   
   # Compute eigenvalues and eigenvectors
   lmbdas, v = np.linalg.eigh(D)
   def compute_FA(lmbdas):
      MD = (lmbdas[:,0] + lmbdas[:,1] + lmbdas[:,2])/3.
      FA2 = (3./2.)*((lmbdas[:, 0]-MD)**2+(lmbdas[:,1]-MD)**2 +(lmbdas[:,2]-MD)**2)/(lmbdas[:,0]**2 + lmbdas[:,1]**2 + lmbdas[:,2]**2)
      FA = np.sqrt(FA2)
      return FA
      
   # Compute fractional anisotropy (FA)
   FA = compute_FA(lmbdas)

   # Define valid entries as those where all eigenvalues are
   # positive and FA is between 0 and 1
   positives = (lmbdas[:,0]>0)*(lmbdas[:,1]>0)*(lmbdas[:,2]>0)
   valid = positives*(FA < 1.0)*(FA > 0.0)
   valid = valid.reshape((M1, M2, M3))

   # Find all voxels with invalid tensors within the mask
   ii, jj, kk = np.where((~valid)*mask)
   print("Number of invalid tensor voxels within the mask ROI: ", len(ii)) 

   # Reshape D from N x 3 x 3 to M1 x M2 x M3 x 9
   D = D.reshape((M1,M2,M3,9))

   return valid, mask, D

if __name__ =='__main__':
   parser = argparse.ArgumentParser()
   parser.add_argument('--dti',type=str)   
   parser.add_argument('--mask', type=str) 
 
   Z = parser.parse_args()

   check_dti_data(Z.dti, Z.mask)





