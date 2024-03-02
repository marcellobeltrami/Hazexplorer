#!/usr/bin/env nextflow

//Defines some preconfigured parameters. 
params.input_dir = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/"


//params.paired_reads = "${params.input_dir}/*{1,2}.fq.gz"
params.paired_reads = '/data/reads/*{1,2}.fq.gz'
params.paired_reads_trim = "${baseDir}/temps/Trimmed/*{1,2}.fq.gz"
params.output = "${baseDir}/results"
params.temps = "${baseDir}/temps"
params.indexed_genome = "${baseDir}/data/references/"

params.parallelize = 1
params.threads = 4
params.reference_gen= "/data/references/Hazelnut_CavTom2PMs-1.0/" //change if new reference genome is required. 
params.indexing= 0
params.sampleId = "Sample 1"

//Infor for the user.
log.info """\

    HAZEXPLORER - NF PIPELINE
    ===================================
    Reads: ${params.paired_reads}
    Reference genome: ${params.reference_gen}



    """


// Trims the reads
process TRIM {
    input:
    path read1  
    val sampleId

    output:
    tuple file ("${params.temps}/Trimmed/${params.sampleId}/trimmed_${read1}") file ("${params.temps}/Trimmed/${params.sampleId}/trimmed_${read2}")

    script:
    """
    mkdir -p "${params.temps}/Trimmed/${params.sampleId}/"

    # Trim paired sequences using fastp (approximately 45 seconds)
    fastp -i "${read1}" -I "${read2}" -o "${params.temps}/Trimmed/${params.sampleId}/trimmed_${read1}" -O "${params.temps}/Trimmed/${params.sampleId}/trimmed_${read2}"
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
process ALIGNMENT {
    input:
    file trimmedRead1
    file trimmedRead2
    path indexed_ref_dir
    output:
    path "*.bam"

    script:
    """
    mkdir -p "${params.temps}/Alignments/${sampleId}"

    bismark --bowtie2 -p ${params.threads} --parallel ${params.parallelize} \
    --genome ${indexed_ref_dir} -1 ${trimmedRead1} -2 ${trimmedRead2} -o ${params.temps}/Alignments/${params.sampleId}
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



workflow{
    //exit if reads are not found
    if (params.paired_readsreads == null){
        
        """
        exit 1, "Paired_reads not specified."
        """
    }
    //Quality control workflow.

    paired_reads= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    
    """
    echo "${paired_reads}"
    """
    
    //Alignement with default references (Hazelnut Tombul). Value of 1 triggers indexing of input refence genome. 
    if (params.indexing == 0) {
        ALIGNMENT(TRIM(paired_reads, params.sampleId) , params.reference_gen, params.sampleId)
        FAST_QC(params.paired_reads_trim)
        //add SNP calling

    //Alignment carrying out the indexing with specified reference genome. 
    } else if (params.indexing== 1) {
        ref_genome_dir = Channel.fromPath(params.reference_gen, type: dir, checkIfExists: true)
        indexed_genome = REF_INDEXING(ref_genome_dir)
        ALIGNMENT(TRIM(paired_reads, params.sampleId), ${indexed_genome}, params.sampleId)
        //add SNP calling
    }

    //BEFORE TESTING ADD INDEXED REF FOR TOMBUL TO DIRECTORY.
    
}