#!/usr/bin/env nextflow

//------------------------------------------RECOMMENDED---------------------------------------------------
//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
sample_name =  "Sample1"
params.fastqc_output = "${baseDir}/results/QC/fastQC/"
params.fastp_output_1 = "${baseDir}/results/QC/fastp/${sample_name}.r1.fastq.gz"
params.fastp_output_2 = "${baseDir}/results/QC/fastp/${sample_name}.r2.fastq.gz"
params.threads = 4


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
//Process carrying QC on reads. 
process FAST_QC{
  publishDir "$params.fastqc_output"

  input: 
   path read 
  
  output: 
    path "*.html"

  script: 
  """ 

  fastqc ${read}\
  --threads $params.threads \
  --quiet true \
  """
}

