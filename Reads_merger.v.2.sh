#!/bin/bash


#SBATCH --ntasks=10
#SBATCH --time=1-00
#SBATCH --qos=bbdefault
#SBATCH --account=cazierj-msc-bioinf
#SBATCH --output=./slurm_logs/slurm-%j.out
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#                         Merges reads into paired mates                   #
#~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~#
#Takes as input the directory with directories containing sample reads and where the mates generated will be stored. 
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
