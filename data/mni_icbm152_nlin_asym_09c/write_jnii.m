pkg load image
addpath('~/octave/iso2mesh/')
addpath('~/octave/zmat/')
addpath('~/octave/brain2mesh/')

if(~exist('jnii/', 'dir'))
	mkdir 'jnii/';
end

nii2jnii('nifti/mni_icbm152_wm_tal_nlin_asym_09c.nii','jnii/mni_icbm152_wm_tal_nlin_asym_09c.jnii', 'compression','lzma');
nii2jnii('nifti/mni_icbm152_gm_tal_nlin_asym_09c.nii','jnii/mni_icbm152_gm_tal_nlin_asym_09c.jnii', 'compression','lzma');
nii2jnii('nifti/mni_icbm152_csf_tal_nlin_asym_09c.nii','jnii/mni_icbm152_csf_tal_nlin_asym_09c.jnii', 'compression','lzma');
