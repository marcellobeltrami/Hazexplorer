#!/usr/bin/env nextflow

//Imports processes from modules.nf file.
include {ALIGNMENT} from  './modules.nf'
include {REF_INDEXING} from  './modules.nf'
include {TRIM} from  './modules.nf'
include {FAST_QC} from  './modules.nf'


//Defines some preconfigured parameters. 
params.input_dir = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/"

single_read= "${params.input_dir }/*.fq.gz" // just for testing, delete

params.paired_reads = "${params.input_dir}/*{1,2}.fq.gz"
params.paired_reads_trim = "${baseDir}/temps/Trimmed/*{1,2}.fq.gz"
params.threads = 4
params.reference_gen= "/data/references/Hazelnut_CavTom2PMs-1.0/" //change if new reference genome is required. 
params.indexing= 0
params.sampleId = "Sample 1"

log.info """\

    HAZEXPLORER - NF PIPELINE
    ===================================
    Reads: ${params.reads}
    Reference genome: ${params.reference_gen}


    """



workflow{
    //Quality control workflow.

    paired_reads= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    
    

    //Alignement step if reference indexing has been carried out. value of 1 triggers indexing of input refence genome 
    if (params.indexing == 0) {
        ALIGNMENT(TRIM(paired_reads, params.sampleId) , params.reference_gen, params.sampleId)
        FAST_QC(params.paired_reads_trim)

    } else if (params.indexing== 1) {
        ref_genome_dir = Channel.fromPath(params.reference_gen, type: dir, checkIfExists: true)
        REF_INDEXING(ref_genome_dir)
        ALIGNMENT(TRIM(paired_reads, params.sampleId), ref_genome_dir, params.sampleId)
    }

    //BEFORE TESTING ADD INDEXED REF FOR TOMBUL TO DIRECTORY.
    
}