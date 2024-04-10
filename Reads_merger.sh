#!/bin/bash


#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                             READ UNIQUE FILES NAME                       #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
target_directory=$1
output_mates=$2

mkdir -p ../temporary_outs
mkdir -p ${output_mates}
mkdir -p ../temporary_outs/unzipped_reads

#Extract unique fasta file names 
name=()

for file in ${target_directory}/*.fq.gz
do
	a=$(echo ${file} | cut -d'_' -f 1)
	b=$(echo ${file} | cut -d'_' -f 2)
	name+=("${a}_${b}")
	

done
unique_fl="${name[@]}" | tr ' ' '\n' | sort -u | tr '\n' ' '

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                             MERGE FILES AND NAMES                        #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#Gunzip all the files and then merge file. 

for fl in ${unique_fl}
do

#Merges reads into two mates reads files
zcat "${fl}"*_1.fq.gz > "${fl}_1.fq"
zcat "${fl}"*_2.fq.gz > "${fl}_2.fq"
done

