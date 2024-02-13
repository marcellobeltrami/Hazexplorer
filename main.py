#!/usr/bin/env python

#Import libraries
import argparse
import os 
import sys
import yaml
import main_modules
#This pipeline will run on a single set of reads. It will then be parallelized on SLURM by user.  

#Creates parser and subparsers objects.  
#Ensure that parameters for tools used are set and obtained from yml file, so they can be modified. 
main_parser= argparse.ArgumentParser(prog="Hazexplorer", 
                                 description="Pipeline allowing SNPs calling from bisulphite sequencing data.")

nextflow_script = open("Hazexplorer.nt", "w")

subparser = main_parser.add_subparsers( dest='subcommand', help='quality_check, align, SNP_call')

#-----------------------------------------------------#
# Creates and defines parser for quality and trimming #
#-----------------------------------------------------#
parser_quality= subparser.add_parser("quality_check", help="Carries out quality check and trimming")

#Adds arguments available, p
parser_quality.add_argument("-1", "--single_end", help="using this flag allows to use single paired reads. Provide ")
parser_quality.add_argument("-t", "--trim", default=True ,help="carries out trimming of the fastq files to remove adapters and other trimming using trimmomatic.")
parser_quality.add_argument("-2", "--paired_ends", default=False ,help="adding a second read activates pair end mode, tells trimming to expect paired ends")
parser_quality.add_argument("-o", "--output", default="./results/QC/", help="change location of output directory")
#arses arguments inputted, assigns relative arguments to variable
args_qual = parser_quality.parse_args()
single_en = args_qual.single_end
pair_en = args_qual.paired_ends
trim_option= args_qual.trim
output_QC = args_qual.output
#Here insert logic and "backend" for trimming.

if args_qual.subcommand == "quality_check":

    main_modules.trim_qc_nt(single_en, output_QC,nextflow_script)
    if pair_en != False: 
        main_modules.trim_qc_nt(single_en, pair_en, output_QC,nextflow_script)  


#Ask joe if sbatch should be included within pipeline or the pipeline will be run with sbatch itself.

#--------------------------------------------------#
# Creates and defines parser for genome alignment  #
#--------------------------------------------------#
parser_align= subparser.add_parser("align", help="Carries out genome alignment")

#Dont forget to include options to carry out genome indexing.



#---------------------------------------------------------#
# Creates and defines parser for SNP calling and trimming #
#---------------------------------------------------------#
parser_SNP= subparser.add_parser("SNP_call", help="Carries out SNP calling")



##Add a section that parses the nextflow script checking for specific process and composes the workflow section. 
