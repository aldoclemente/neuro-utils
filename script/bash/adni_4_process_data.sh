#! /bin/bash

UTILSDIR=~/Desktop/neuro-utils

# Secondo documentazione ADNI3, MRI non hanno bisogno di essere preprocessate perché correzioni vengono fatte automaticamente.
for sub in `ls`; do
	cd $T1DIR
	k=0
	for date in */; do
		mv date $k
		bet unwarped.nii.gz unwarped_bet.nii.gz -B -f 0.15 # -B Bias Field & Neck cleanup (necessario)
		flirt -ref $UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c_brain.nii.gz -in unwarped_bet.nii.gz -omat affine_transf.mat
		fnirt --in=unwarped.nii.gz --aff=affine_transf.mat --cout=nonlinear_transf --config=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/config
		applywarp --ref=$UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c.nii \
		  --in=unwarped.nii.gz --warp=nonlinear_transf --out=warped.nii.gz
slice warped.nii.gz $UTILSDIR/data/mni_icbm152_nlin_asym_09c/nifti/mni_icbm152_t1_tal_nlin_asym_09c.nii -o slices.png
		k=$(($k+1))
	done
	cd .. # $sub
	
	cd $DTIDIR
	
	# problema perché i nomi delle directory non matchano
	k=0
	for date in */; do
		mv date $k
		fslroi raw.nii nodif 0 1
		python3 $UTILSDIR/script/python/build_acqparam.py --input raw.json
		echo "0 1 0 0.000" >>  acqparams.txt 
		# touch acqparams.txt # ma devi leggere un file json...
		#prepare directory for Synb0-DISCO
		vols=($(wc -w raw.bval))
		indx=""
		for ((i=1; i<=$vols; i+=1)); do indx="$indx 1"; done
		echo $indx > index.txt
		mkdir Synb0-inputs
		cp ../$T1DIR/$k/unwarped_bet.nii.gz Synb0-inputs/T1.nii.gz
		cp nodif.nii.gz Synb0-inputs/b0.nii.gz
		cp acqparams.txt Synb0-inputs/acqparams.txt
		
		mkdir Synb0-outputs
		
		# 1. run Synb0 ( + FSL topup, lanciato automaticamente)
		docker run --rm -v $(pwd)/Synb0-inputs/:/INPUTS/ -v $(pwd)/Synb0-outputs:/OUTPUTS/ \
							 -v $FREESURFER_HOME/license.txt:/extra/freesurfer/license.txt \
							 --user $(id -u):$(id -g) leonyichencai/synb0-disco:v3.1 --stripped # NB passagli direttamente quello che è stato skull stripped
		
		k=$(($k+1)) #:)
	done 
	
done

# Allora...
# MNI152 standard di FSL è la versione asym. del MNI152 VI generazione SIM del 2006.
# FSL da anche le mappe di probabilità del tessuto $FSLDIR/standard/tissuepriors/ SOLO per 2mm 
# Penso non lo abbia fatto lei direttamente... 
# Dall'articolo i dati sembrano già disponibili...
