#!/usr/bin/env nextflow

//------------------------------------------RECOMMENDED---------------------------------------------------
//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
params.sample_name =  "Sample1"
params.fastqc_output = "./results/QC/fastQC/"
params.fastp_output_1 = "./results/QC/fastp/${sample_name}.r1.fastq.gz"
params.fastp_output_2 = "./results/QC/fastp/${sample_name}.r2.fastq.gz"



//Example of syntax. Adjust accordingly
process PREPARE_GENOME_SAMTOOLS { 
  tag "$genome.baseName" 
 
  input: 
    path genome //input expected when calling this process PREPARE_GENOME_SAMTOOLS(genome)
 
  output: 
    path "${genome}.fai"
  
  script:
  """
  samtools faidx ${genome}
  """
}



//------------------------------------------NON-MANDATORY---------------------------------------------------
//These are the settings used for fastqc. Setting parameter to true will include it in the analysis. 
//Changing threads number to an integer (whole number) will increase quality checking speed.
process FAST_QC{
  publishDir "$params.fastqc_output"

  input: 
   path read 
  
  output: 
    path "*.html"
  
  script: 
  """ 
  fastqc ${read}\
  --outdir ${fastqc_output} \
  --threads 4 \
  --quiet true \
  """



}

//Fastp settings used for trimming. Setting parameter to true will include it in the analysis. 
process TRIM{


  script: 
  """ 
  threads: 4 
  dont_overwrite: false
  adapter_sequence: false //Specify adapter sequence as a filepath
  adapter_sequence_r2: false //Specify adapter sequence for r2 as a filepath
  failed_out: false}
  ""