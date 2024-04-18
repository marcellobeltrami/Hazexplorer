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
# Usr parameters. Please change this according file location. 
samples_directories=$(find "$1" -mindepth 1 -maxdepth 1 -type d)
merged_reads="${2:-/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazexplorer/data/merged_reads}"
merging_required="${3:-n}"
#-------------------------------------------------------------#
#Check if usr parameters have been inputted. 
if [ $# -eq 0 ]; then
    echo "Usage: $0 <Full path containing all samples directories> <Full path Output directory where all merged samples will be stored (default is directory used in dev)>"
    exit 1
fi

# Check if the input directory exists
if [ ! -d "$input_directory" ]; then
    echo "Error: Input directory '$input_directory' not found."
    exit 1
fi

##Add if statement that checks whether merging reads is required (default is no). 
if [${merging_required} != n]; then 
    #Merged reads folder is created and will be used 
    mkdir -p ${merged_reads}

    # Executions side. Does not need changing. Takes each directory and inputs it in the merging script.  
    for sample_dir in ${samples_directories}; do 
        echo ${sample_dir}
        sbatch Reads_merger.v.2.sh ${sample_dir} ${merged_reads}

    done 

fi


#Runs nextflow pipeline found in main_hazex_v.2.nf using the merged paired reads 
nextflow -log ./nf_logs/nextflow.log run main_hazex_v.2.nf --paired_reads=${merged_reads}/*{1,2}.fq.gz -with-report ./nf_logs/Run_report
 
