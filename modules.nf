#!/usr/bin/env nextflow

//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
sample_name =  "Sample1"
params.output = "${baseDir}/results/"
params.fastp_output_1 = "${baseDir}/results/QC/fastp/${sample_name}.r1.fastq.gz"
params.fastp_output_2 = "${baseDir}/results/QC/fastp/${sample_name}.r2.fastq.gz"
params.threads = 4




//------------------------------------------NON-MANDATORY---------------------------------------------------
//Process carrying QC on reads. 
process FAST_QC{
  publishDir "${params.output}/QC/"

  input: 
   path read 
  
  output: 
    path "*.html"

  script: 
  """ 
  mkdir -p ${params.output}/QC/
  fastqc ${read}\
  --threads ${params.threads} \
  --quiet true \
  """
}


//Trims the reads
process TRIM{
  publishDir "${params.output}/results/Trimmed"

  input: 
   path read

  output: 
    path "*.fastq.gz"
  
  script: 
  """
  mkdir -p "${params.output}/results/Trimmed"
  ## add fastp command 
  """

}