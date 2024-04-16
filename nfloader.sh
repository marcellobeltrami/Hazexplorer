#!/bin/bash

#SBATCH --ntasks=10
#SBATCH --time=4-00
#SBATCH --qos=bbdefault
#SBATCH --account=cazierj-msc-bioinf
#SBATCH --output=./slurm_logs/slurm-%j.out


module purge; module load bluebear
module load  bear-apps/2021b/live; module load  Nextflow/22.04.0
#Adjust time and ntasks depending on the amount of samples you have. 
#-------------------------------------------------------------#
# Usr parameters. Please change this according file location 
samples_directories=$(find $1 -mindepth 1 -maxdepth 1 -type d) #(change to $1)     
merged_reads=$2 #(change to $2)

#-------------------------------------------------------------#
#Check if usr parameters have been inputted. 
if [ $# -eq 0 ]; then
    echo "Usage: $0 <Full path containing all samples directories> <Full path Output directory where all merged samples will be stored>"
    exit 1
fi

#Merged reads folder is created and will be used 
mkdir -p ${merged_reads}

# Executions side. Does not need changing. Takes each directory and inputs it in the merging script.  
for sample_dir in ${samples_directories}; do 
	echo ${sample_dir}
	./Reads_merger.v.2.sh ${sample_dir} ${merged_reads}

done 


#Runs nextflow pipeline found in main_hazex_v.2.nf using the merged paired reads 
nextflow -log ./nf_logs/nextflow.log run main_hazex_v.2.nf --paired_reads=${merged_reads}/*{1,2}.fq.gz
 
