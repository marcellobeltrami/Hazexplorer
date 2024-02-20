#!/usr/bin/env nextflow

//Imports processes from modules.nf file.
include { FAST_QC } from './modules.nf'
include { TRIM } from './modules.nf'

params.input_dir = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/*.fq.gz"
params.paired_reads = "${input_dir}/*{1,2}.fq.gz"
params.reference_gen= ""


log.info """\

    HAZEXPLORER - NF PIPELINE
    ===================================
    Reads: ${params.reads}
    Reference genome: ${params.reference_gen}


    """



//Quality control workflow.
workflow{
    reads_data= Channel.fromPath(params.input_dir, checkIfExists: true) 
    FAST_QC(reads_data)
}

//Trimming and quality control workflow.
workflow{
    paired_reads= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    TRIM(paired_reads) | FAST_QC()

}