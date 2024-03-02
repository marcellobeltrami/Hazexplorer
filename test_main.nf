#!/usr/bin/env nextflow


params.paired_reads = './data/reads/*{1,2}.fq.gz'
params.reference_gen= "./data/references/Hazelnut_CavTom2PMs-1.0/"

//GLobal variables
trimmed_outputs= "${baseDir}/data/trimmed/"
temps = 

//Infor for the user.
log.info """\

    HAZEXPLORER - NF PIPELINE
    ===================================
    Reads: ${params.paired_reads}
    Reference genome: ${params.reference_gen}

    """


// Trims the reads
process TRIM {
    tag {sampleId}
    publishDir "${trimmed_outputs}/${sampleId}"
    
    input:
    tuple val(sampleId) , path(reads) 

    output:
    tuple val(sampleId), path ("*.fastq.gz")

    script:
    def (read1, read2) = reads
    """
    mkdir -p "${trimmed_outputs}${sampleId}"

    # Trim paired sequences using fastp (approximately 45 seconds)
    fastp -i "${read1}" -I "${read2}" \
    -o "${sampleId}_trimmed_1.fastq.gz" \
    -O "${sampleId}_trimmed_2.fastq.gz"
    """
}

workflow{


    paired_reads_ch= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    paired_reads_ch.view()
    
    TRIM(paired_reads_ch)

}