#! /bin/bash

help()
{
    echo "Usage: ./dowload_adni_data.sh [-i|h]

       -i          input file 
       -h 		   shows this message"
    exit 2
}

INPUTFILE=""

while getopts "hi:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      i) 
         INPUTFILE=$OPTARG;;
     \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done


while read link; do
   wget ${link}
done < $INPUTFILE

