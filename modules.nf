#!/usr/bin/env nextflow

//list of all the directories where outputs of relative analysis should be sent. Default will be sent to Results
//Modify sample name
output = "${baseDir}/results"
temps = "${baseDir}/temps"
indexed_genome = "${baseDir}/data/references/"





//------------------------------------------PROCESSES---------------------------------------------------//


// Trims the reads
process TRIM {
    input:
    file read1
    file read2 
    val sampleId

    output:
    tuple file ("${temps}/Trimmed/${sampleId}/trimmed_${read1}") file ("${temps}/Trimmed/${sampleId}/trimmed_${read2}")

    script:
    """
    mkdir -p "${temps}/Trimmed/${sampleId}/"

    # Trim paired sequences using fastp (approximately 45 seconds)
    fastp -i "${read1}" -I "${read2}" -o "${temps}/Trimmed/${sampleId}/trimmed_${read1}" -O "${temps}/Trimmed/${sampleId}/trimmed_${read2}"
    """
}

//Process carrying QC on reads. 
process FAST_QC{
  publishDir "${output}/QC"

  input: 
   tuple trim_reads 
   val threads
  output: 
    path "*.html"

  script: 
  """ 
  mkdir -p ${output}/QC/
  fastqc ${read}\
  --threads ${threads} \
  --quiet true \
  --output ${output}/
  """
}


//Defines reference indexing for Bismark aligner. 
process REF_INDEXING{

    input:
    path(refdir) from ref_genome_dir 
    val ref_name
    

    output: 
    path "${indexed_genome}/${ref_name} "

    script:
    """
    mkdir -p "${indexed_genome}/${ref_name}"

    bismark_genome_preparation --path_to_aligner /usr/bin/bowtie2/ --verbose ${ref_dir} -o "${indexed_genome}/${ref_name}"
    """
}



//Carries out alignment using trimmed reads. 
// Carries out alignment using trimmed reads.
process ALIGNMENT {
    input:
    file trimmedRead1
    file trimmedRead2
    path indexed_ref_dir
    val sampleId
    val threads
    val parallelize
    output:
    path "*.bam"

    script:
    """
    mkdir -p "${params.temps}/Alignments/${sampleId}"

    bismark --bowtie2 -p ${threads} --parallel ${parallelize} \
    --genome ${indexed_ref_dir} -1 ${trimmedRead1} -2 ${trimmedRead2} -o ${params.temps}/Alignments/${sampleId}
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
