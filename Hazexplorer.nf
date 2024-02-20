#!/usr/bin/env nextflow

//Imports processes from modules.nf file.
include { FAST_QC } from './modules.nf'
//include { TRIM } from './modules.nf'

params.reads = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/*.fq.gz"
params.paired_reads = "data/*{1,2}.fq.gz"
params.reference_gen= ""


log.info """\

    HAZEXPLORER - NF PIPELINE
    ===================================
    Reads: ${params.reads}
    Reference genome: ${params.reference_gen}


    """



//Qulaity control workflow.
workflow{
    reads_data= Channel.fromPath(params.reads, checkIfExists: true) 
    FAST_QC(reads_data)
}