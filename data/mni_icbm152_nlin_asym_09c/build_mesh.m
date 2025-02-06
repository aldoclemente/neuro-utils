pkg load image
addpath('~/octave/iso2mesh/')
addpath('~/octave/zmat/')
addpath('~/octave/brain2mesh/')

if(~exist('jnii/', 'dir'))
	run writejnii.m
end

wm =  loadjnifti('jnii/mni_icbm152_wm_tal_nlin_asym_09c.jnii');
gm =  loadjnifti('jnii/mni_icbm152_gm_tal_nlin_asym_09c.jnii');
#csf = loadjnifti('jnii/mni_icbm152_csf_tal_nlin_asym_09c.jnii');
mni.wm = wm.NIFTIData;
mni.gm = gm.NIFTIData;
#mni.csf = csf.NIFTIData;
cfg.radbound.wm=1.7; # default 1 x 1 x 1 mm
cfg.radbound.gm=1.7; # default 1 x 1 x 1 mm
#cfg.radbound.csf=2; 
cfg.smooth = 5; 
cfg.maxvol = 100;
[nodes,elements,faces] = brain2mesh(mni, cfg);

if(~exist('mesh/', 'dir'))
	mkdir 'mesh/';
end

save 'mesh/nodes.mat' nodes;
save 'mesh/elements.mat' elements;
save 'mesh/faces.mat' faces;
system('tail -n +6 mesh/nodes.mat > mesh/nodes.txt')
system('tail -n +6 mesh/elements.mat > mesh/elements.txt')
system('tail -n +6 mesh/faces.mat > mesh/faces.txt')





