#!/usr/bin/env nextflow

//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
params.output = "${baseDir}/results"
params.temps = "${baseDir}/temps"
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
  publishDir "${params.temps}/Trimmed/"

  input: 
   tuple file(read1), file(read2)
  output: 
    path "*.fastq.gz"
  
  script: 
  """
  mkdir -p "${params.temps}/Trimmed"

  ./bin/reads_quality.sh ${read1} ${read2} ${params.temps}/Trimmed

  """

}