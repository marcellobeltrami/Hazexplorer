#!/bin/bash

#SBATCH --ntasks=10
#SBATCH --time=4-00
#SBATCH --qos=bbdefault
#SBATCH --account=cazierj-msc-bioinf
#SBATCH --output=./slurm_logs/slurm-%j.out


module purge; module load bluebear
module load  bear-apps/2021b/live; module load  Nextflow/22.04.0

#-------------------------------------------------------------#
# Usr parameters. Please change this according file location 

samples_directories=$(find /rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazexplorer/data/reads -mindepth 1 -maxdepth 1 -type d) #(change to $1)     
merged_reads="/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazexplorer/data/merged_reads" #(change to $2)

#-------------------------------------------------------------#
#Check if usr parameters have been inputted. 

#if [ $# -eq 0 ]; then
#    echo "Usage: $0 <Full path containing all samples directories> <Full path Output directory where all merged samples will be stored>"
#    exit 1
#fi


mkdir -p ${merged_reads}

# Executions side. Does not need changing. 
for sample_dir in ${samples_directories}; do 
	echo ${sample_dir}
	./Reads_merger.sh ${sample_dir} ${merged_reads}

done 


#nextflow -log ./nf_logs/nextflow.log run main_hazex_v.2.nf --paired_reads=${merged_reads}/*{1,2}.fq.gz
 

#nextflow -log ./nf_logs/nextflow.log run  main_hazex_v.2.nf
