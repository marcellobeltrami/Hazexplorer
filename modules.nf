#!/usr/bin/env nextflow

//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
params.output = "${baseDir}/results"
params.temps = "${baseDir}/temps"

params.threads = 4
params.parallelize = 5
params.sampleId= "Sample 1"




//------------------------------------------PROCESSES---------------------------------------------------
//Process carrying QC on reads. 
process FAST_QC{
  publishDir "${params.output}/QC"

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
  //publishDir "${params.temps}/Trimmed/${params.sampleId}/"

  input: 
   file(read1)
   file(read2)
   val sampleId
  output:
    file(trimmedRead1)
    file(trimmedRead2)
  
  script: 
  """
  mkdir -p "${params.temps}/Trimmed/${sampleId}/"

  #trimms paired sequences. This takes ~45seconds
  fastp -i "${read1}" -I "${read2}" -o "./temps/Trimmed/${sampleId}/trimmed_${read1}"  -O "./temps/Trimmed/${sampleId}/trimmed_${read2}"

  """

}


//Defines reference indexing for Bismark aligner. 
process REF_INDEXING{

    input:
    path(refdir) from ref_genome_dir 

    script:
    """
    
    """
}



//Carries out alignment using trimmed reads. 
process ALIGNMENT{
  //publishDir "${params.temps}/Alignments/${params.sampleId}"

  input: 
   file(trimmedRead1)
   file(trimmedRead2)
   path indexed_ref_dir
   val sampleId
  output: 
    path "*.bam" 


  script: 
  """
  mkdir -p "${params.temps}/Alignments/${sampleId}"

  bismark --bowtie2 -p ${params.threads} --parallel ${params.parallelize} \
  --genome ${indexed_ref_dir} -1 ${trimmedRead1} -2 ${trimmedRead2} -o ${sampleId}  
  """

}


//Carries out SNP calling. 
process SNP_CALLING{
  publishDir "${params.temps}/SNP_calls/${params.sampleId}"

  input: 
   path "${params.temps}/Alignments/${params.sampleId}/*.bam"
  
  output: 
    path "*.bam" 

  script:
  """
  mkdir -p "${params.output}/SNP_calls/${params.sampleId}"

  ##Wait to determine nest caller. 

  """
    
}
