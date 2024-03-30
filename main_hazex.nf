#!/usr/bin/env nextflow


// params. use --parameter_name to change parameter
params.paired_reads = './data/reads/*{1,2}.fq.gz' // remember to change this to null. Use example --paired_reads='./data/reads/*{1,2}.fq.gz'
params.reference_genome= "${baseDir}/data/references/Hazelnut_CavTom2PMs-1.0/fasta_ref" //This path should be the full path to reference genome.
params.reference_name = "reference_name"
params.results = "./results"
params.temps = "${baseDir}/temps"
params.index_requirement = 0 //change this to null 
params.parallelize = 4
params.threads = 6

// Help function with useful parameters.
def help = params.help ?: false
if (params.help){
    log.info """\
    
    Command options:
    
    --paired_reads=<pattern>      Path to paired-end reads in FASTQ format.  Use the pattern "./data/reads/*{1,2}.fq.gz". By default reads are looked into the ./data/reads/ directory
    --reference_genome=<path>     Full path to the reference genome in FASTA format.
    --reference_name=<name>       Name for the reference genome.
    --results=<directory>         Directory to store the pipeline results (default: ./results).
    --index_requirement=<value>   Specify an integer (0 or 1) to indicate if indexing the reference genome is required (0: not required, 1: required).
    --parallelize=<value>         Specify the level of parallelization (default: 1).
    --threads=<value>             Specify the number of threads to use for parallel tasks (default: 4).
    --help                        Display this help message and exit.
    """
    exit (" ")
}


// Global variables
trimmed_outputs= "${baseDir}/data/trimmed/"
indexed_reference = "${baseDir}/data/references/"
temps = "${baseDir}/temps/"

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

    HAZEXPLORER - NF PIPELINE
    ===================================
    
    Reads: ${params.paired_reads}
    Reference genome: ${params.reference_genome}

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
    set -e

    module purge; module load bluebear
    module load bear-apps/2021b/live
    module load fastp/0.23.2-GCC-11.2.0

    mkdir -p "${trimmed_outputs}${sampleId}"

    # Trim paired sequences using fastp (approximately 45 seconds)
    fastp -i "${read1}" -I "${read2}" \
    -o "${sampleId}_trimmed_1.fastq.gz" \
    -O "${sampleId}_trimmed_2.fastq.gz"
    """
}


//Indexes reference genome based on bowtie2 algorithm.
process INDEX{
    
    publishDir "${indexed_reference}/${reference_name}/"
    
    input: 
        path reference_genome
    output: 
        path "${params.reference_name}/*"
    script:

    """
    set -e

    module purge 
    module load bluebear 
    module load bear-apps/2021b
    module load Bismark/0.24.2-foss-2021b

    
    bismark_genome_preparation --aligner bowtie2 --verbose ${reference_genome} -o ${params.reference_name}/ 
    """
// change path to aligner so it not /usr/bin/bowtie2, but just bowtie2.  
}

process FAST_QC{
    tag {sampleId}
    publishDir "${params.results}/QC/${sampleId}"
    
    input:
    tuple val(sampleId) , path(reads) 

    output: 
    path "*.html"
    path "*.html"


    script:
    def (read1, read2) = reads
    """
    set -e

    module purge; module load bluebear
    module load bear-apps/2021b/live
    module load FastQC/0.11.9-Java-11
    
    
    mkdir -p "${params.results}/QC/${sampleId}"

    fastqc ${read1} --threads ${params.threads} --quiet true --output ${sampleId}_QC_1
    fastqc ${read2} --threads ${params.threads} --quiet true --output ${sampleId}_QC_2
    """
}

//Aligns reads using bismark and bowtie2 
process ALIGNMENT {
    tag {sampleId}
    
    input:
    tuple val(sampleId) , path(reads) 
    path indexed_reference_directory 
    
    output:
    tuple val(sampleId), path ("${sampleId}_unsorted.bam")
    

    script:
    def (trimmedRead1, trimmedRead2) = reads
    """
    set -e

    module purge; module load bluebear 
    module load bear-apps/2021b
    module load Bismark/0.24.2-foss-2021b

    mkdir -p "${params.temps}/Alignments/${sampleId}"

    bismark --bowtie2 -p ${params.threads} --multicore ${params.parallelize} --genome ${indexed_reference_directory} -1 ${trimmedRead1} -2 ${trimmedRead2} -o ${params.sampleId}
    """
}


//Create Picard Sorting in preparation for SNP calling

process PICARD{
    tag {sampleId}


    input:
    tuple val(sampleId), path ("${sampleId}_unsorted.bam")

    output: 
    tuple val(sampleId), path ("${sampleId}_pic_uns.bam")
    

    """
    set -e 

    module purge; module load bluebear
    module load bear-apps/2022b/live
    module load picard/2.27.5-Java-11

    java -Xmx4g -jar picard.jar AddOrReplaceReadGroups \
    I=${sampleId}_unsorted.bam \
    O=${params.results}/Alignments/${sampleId}/ \
    RGID=${sampleId}_RG \
    RGLB=Unknown \
    RGPL=ILLUMINA \
    RGPU=Unknown \
    RGSM=${sampleId} \
    CREATE_INDEX=false

    """

}

//carries out sorting of BAM files edited with PICARD. 
process SAMTOOLS{
    tag {sampleId}

    publishDir "${params.results}/Alignments/${sampleId}/"

    input:
    tuple val(sampleId), path ("${sampleId}_pic_uns.bam")

    output: 
    tuple val(sampleId), path ("${sampleId}_pic_sorted.bam"), path ("${sampleId}_pic_sorted.bai")
    

    """
    set -e

    module purge; module load bluebear 
    module load bear-apps/2022b/live
    module load SAMtools/1.17-GCC-12.2.0

    samtools sort ${sampleId}_pic_uns.bam -o ${sampleId}_pic_sorted.bam
    samtools index ${sampleId}_pic_sorted.bam -o ${sampleId}_pic_sorted.bai
    """


}



//Create a process for SNP calling.
process BIS_SNP {
    tag { sampleId }
    publishDir "${params.results}/results/${sampleId}/"

    input:
    tuple val(sampleId), path("${sampleId}_pic_sorted.bam"), path("${sampleId}_pic_sorted.bai")

    output:
    tuple val(sampleId), file("${sampleId}_*.vcf"), file("${sampleId}_summary_count.txt")

    script:
    """
    set -e

    module purge; module load bluebear
    module load bear-apps/2022b/live
    module load Java/17.0.6
    module load SAMtools/1.17-GCC-12.2.0
    module load GATK/4.4.0.0-GCCcore-12.2.0-Java-17

    # Calls SNPs using BisSNP
    java -Xmx4g -jar ./tools/BisSNP-0.90.jar -R ${ref_location} \
    -t 10 -T BisulfiteGenotyper -I ${sampleId}_pic_sorted.bam \
    -vfn1 ${sampleId}_cpg.raw.vcf -vfn2 ${sampleId}_snp.raw.vcf

    # Add command that Generates a summary table and graph for SNP amount found at each chromosome.
    
    """
}


// Acts as the MAIN function, running each process in the most optimal way.
workflow{

    //reads mates from a specified directory.
    paired_reads_ch= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    paired_reads_ch.view()
    
    paired_trimmed = TRIM(paired_reads_ch)
    FAST_QC(paired_trimmed) //produces a QC report of trimmed reads. 

   
    //called if reference genome is default or does not need indexing.
    if (params.index_requirement == 0){
        aligned_bam = ALIGNMENT(paired_trimmed, params.reference_genome)
        picard_out = PICARD(aligned_bam)
        samtools_out = SAMTOOLS(picard_out)
        bis_snp_out = BIS_SNP(samtools_out)
            
    }
    //called if reference genome is custom and needs to be indexed.
    if (params.index_requirement == 1){
        indexed_reference = INDEX(params.reference_genome)
        aligned_bam = ALIGNMENT(paired_reads_trim, indexed_reference)
        picard_out = PICARD(aligned_bam)
        samtools_out = SAMTOOLS(picard_out)
        bis_snp_out = BIS_SNP(samtools_out)
    }

}