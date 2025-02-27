#!/bin/bash


# $1 # path to ADNI
DIR=$(pwd)
cd $1
for sub in `ls`; do
	cd $sub
	echo $sub
	cd DTI
	for date in */; do
		echo $date 
		cat $date/raw.bval | tr ' ' '\n' | sort -n | uniq -c
	done
	cd ..
	cd ..
done

cd $DIR
