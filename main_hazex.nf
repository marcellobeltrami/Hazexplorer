#!/usr/bin/env nextflow


// params. use --parameter_name to change parameter
params.paired_reads = "./data/reads/" // remember to change this to null. Use example --paired_reads='./data/reads/directory'
params.merged_reads_out = "./data/merged_reads/"

// Help function with useful parameters.
def help = params.help ?: false
if (params.help){
    log.info """\
    
    Command options:
    
    --paired_reads=<directories>      Path to paired-end reads in FASTQ format.  Use the pattern "./data/reads/*{1,2}.fq.gz". By default reads are looked into the ./data/reads/ directory
    --merged_reads_out=<directory> Path to directory where merged files should be saved
    """
    exit (" ")
}

// Checks if fundamental parameters have been specified.
if (params.paired_reads == null) {
      println("Specify reads using paired_reads")
      exit(1)
}

if (params.index_requirement == null){
    println("Specify integer for indexing the reference genome is necessary. (0: non required, 1: required)")
    exit(1)
}

// Info for the user.
log.info """\

    HAZEXPLORER - Reads merger 
    ===================================
    
    Reads directories: ${params.paired_reads}
    """

process PUBLISH_READS{

    input: 
        tuple libraryId, mergedFile1, mergedFile2

    output: 
        path *
    """
    cp ${mergedFile1} ${params.merged_reads_out}/data/merged_reads/${libraryId}_R1.fastq.gz
    cp ${mergedFile2} ${params.merged_reads_out}/data/merged_reads/${libraryId}_R2.fastq.gz 

    """
}

   



// Acts as the MAIN function, running each process in the most optimal way.
workflow{
    //reads mates from a specified directory.
    
    for (directory in file(params.paired_reads).listDirectories()) {
    def directoryPath = directory.toString()
    def paired_reads_ch = Channel.fromFilePairs("${directoryPath}/*.fastq", flat: true)
        .map { prefix, file1, file2 -> tuple(getLibraryId(prefix), file1, file2) }
        .groupTuple()
        .map { libraryId, fileList ->
            def mergedFile1 = merge(fileList.collect { it[1] })
            def mergedFile2 = merge(fileList.collect { it[2] })
            tuple(libraryId, mergedFile1, mergedFile2)
        }
    process PUBLISH_READS(paired_reads_ch)
}
    
    
   

}