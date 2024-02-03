#!/usr/bin/env python

#Import libraries
import argparse
import os 
import sys
import yaml

#This pipeline will run on a single set of reads. It will then be parallelized on SLURM by user.  

#Creates parser and subparsers objects.  
#Ensure that parameters for tools used are set and obtained from yml file, so they can be modified. 
main_parser= argparse.ArgumentParser(prog="Hazexplorer", 
                                 description="Pipeline allowing SNPs calling from bisulphite sequencing data.")

subparser = main_parser.add_subparsers(title='subcommands', dest='subcommand', help='quality_check, align, SNP_call')

#-----------------------------------------------------#
# Creates and defines parser for quality and trimming #
#-----------------------------------------------------#
parser_quality= subparser.add_parser("quality_check", help="Carries out quality check and trimming")

#Adds argumetns available, parses arguments inputted, assigns relative arguments to variable
parser_quality.add_argument("-t", "--trim", default=True ,help="carries out trimming of the fastq files to remove adapters and other trimming using trimmomatic.")
parser_quality.add_argument("-p", "--paired_ends", default=False ,help="setting this to True,  tells trimming to expect as paired ends")
parser_quality.add_argument("-q", "--quality_control", default=True ,help="carries out quality control using FastQC. Set to False to disable it")

args_qual = parser_quality.parse_args()

pair_en = args_qual.paired_ends()
trim_option= args_qual.trim()
QC = args_qual.quality_control()

#Here insert logic and "backend" of your app.

#--------------------------------------------------#
# Creates and defines parser for genome alignment  #
#--------------------------------------------------#
parser_align= subparser.add_parser("align", help="Carries out genome alignment")

#Dont forget to include options to carry out genome indexing.



#---------------------------------------------------------#
# Creates and defines parser for SNP calling and trimming #
#---------------------------------------------------------#
parser_SNP= subparser.add_parser("SNP_call", help="Carries out SNP calling")



