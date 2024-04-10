#!/bin/bash


#SBATCH --ntasks=10
#SBATCH --time=1-00
#SBATCH --qos=bbdefault
#SBATCH --account=cazierj-msc-bioinf

#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                         Merges reads into paired mates                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
target_directory=$1
output_mates=$2

sample_name=$(basename ${target_directory} )


# Optimize this step, as unzipped reads take up too much space. 

echo "Merging and zipping ${sample_name} files..."

# Merge and gzip _1.fq.gz files
zcat "${target_directory}"/*_1.fq.gz | gzip > "${output_mates}/${sample_name}_1.fq.gz"

# Merge and gzip _2.fq.gz files
zcat "${target_directory}"/*_2.fq.gz | gzip > "${output_mates}/${sample_name}_2.fq.gz"

echo "${sample_name} done!"
