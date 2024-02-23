#!/usr/bin/env nextflow

//Imports processes from modules.nf file.
include { FAST_QC } from './modules.nf'
include { TRIM } from './modules.nf'
include { ALIGNMENT } from './modules.nf'

params.input_dir = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/*.fq.gz"
params.paired_reads = "${input_dir}/*{1,2}.fq.gz"
params.threads = 4
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


//Trimming quality control and alignment workflow.
workflow{
    paired_reads= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    reads_trimmed = TRIM(paired_reads) 
    FAST_QC(reads_trimmed)

    //Alignement step using 
    paired_reads_trim = "${baseDir}/temps/Trimmed/*{1,2}.fq.gz"
    ALIGNMENT(paired_reads_trim)
    

}