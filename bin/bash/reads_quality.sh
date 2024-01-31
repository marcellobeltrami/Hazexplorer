#!/bin/bash

#SBATCH --ntasks=1
#SBATCH --time=15:00
#SBATCH --qos=bbdefault


set -e

module purge; module load bluebear
module load bear-apps/2021b/live
module load FastQC/0.11.9-Java-11
module load fastp/0.23.2-GCC-11.2.0
#bash script carrying out quality control and trimming on all samples in a directory.


#reads in untrimmed sequences (passed as script parameters). Also keeps only the base name. 
read1_path="$1"
read2_path="$2"
read1_name=$(basename "$read1_path")
read2_name=$(basename "$read2_path")

#trimms paired sequences. This takes ~45seconds
fastp -i "$read1_path" -I "$read2_path" -o "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out/$read1_name"  -O "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out/$read2_name" 


#retrieves trimmed sequences
trimmed1="/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_ou/$read1_name"
trimmed2="/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out/$read2_name"

#conducts QC on trimmed sequences
fastqc "$trimmed1" -t 2 -o "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out"
fastqc "$trimmed2" -t 2 -o "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/TrimQC_out"


