#!/usr/bin/env nextflow


include { FAST_QC } from './modules.nf'
include { TRIM } from './modules.nf'

params.reads = "data/reads/*.fq.gz"
params.paired_reads = "data/*{1,2}.fq.gz"
workflow{
    Channel.fromFilePath(params.reads, checkIfExists: true) 
        | FAST_QC()
    

}