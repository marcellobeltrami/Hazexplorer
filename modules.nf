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
    tuple file(trimmedRead1), file(trimmedRead2)
  
  script: 
  """
  mkdir -p "${params.temps}/Trimmed/"

  #trimms paired sequences. This takes ~45seconds
  fastp -i "${read1}" -I "${read2}" -o "./temps/Trimmed/trimmed_${read1}"  -O "./temps/Trimmed/trimmed_${read2}"

  """

}


//Carries out alignment using trimmed reads. 
process ALIGNMENT{
  publishDir "${params.temps}/Alignments/"

  input: 
   tuple file(trimmedRead1), file(trimmedRead2)
  
  output: 
    

  script: 
  """
  
  """

}


