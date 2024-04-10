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

echo "Merging ${sample_name} files..."
zcat ${target_directory}/*_1.fq.gz >> "${output_mates}/${sample_name}_1.fq"  
zcat ${target_directory}/*_2.fq.gz >> "${output_mates}/${sample_name}_2.fq"

echo "Zipping ${sample_name} merged reads..."
gzip "${output_mates}/${sample_name}_1.fq" 
gzip "${output_mates}/${sample_name}_2.fq"

rm "${output_mates}/${sample_name}_1.fq" 
rm "${output_mates}/${sample_name}_2.fq" 

echo "${sample_name} done!"