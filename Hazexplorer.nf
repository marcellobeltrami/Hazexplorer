#!/usr/bin/env nextflow


include { FAST_QC } from './modules.nf'
//include { TRIM } from './modules.nf'

params.reads = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/*.fq.gz"
params.paired_reads = "data/*{1,2}.fq.gz"
workflow{
    reads_data= Channel.fromPath(params.reads, checkIfExists: true) 
    FAST_QC(reads_data)
    

}