#!/usr/bin/env nextflow

//https://www.nextflow.io/blog/2021/5_tips_for_hpc_users.html (investigate slurm integration with Nextflow.)


//params. use --parameter_name to change parameter
params.paired_reads = './data/reads/*{1,2}.fq.gz' // remember to change this to null. Use example --paired_reads='./data/reads/*{1,2}.fq.gz'
params.reference_genome= "./data/references/Hazelnut_CavTom2PMs-1.0/fasta_ref"
params.reference_name = "reference_name"
params.results = "./results"

params.index_requirement = 0 //change this to null 
params.parallelize = 1
params.threads = 4

//Global variables
trimmed_outputs= "${baseDir}/data/trimmed/"
indexed_reference = "${baseDir}/data/references/"
temps = "${baseDir}/temps/"

//Checks if fundamental parameters have been specified.
if (params.paired_reads == null) {
      println("Specify reads using paired_reads")
      exit(1)
}

if (params.index_requirement == null){
    println("Indicate integer for indexing the reference genome is necessary. (0: non required, 1: required)")
    exit(1)
}

//Infor for the user.
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
    #SBATCH --ntasks=1
    #SBATCH --time=15:00
    #SBATCH --qos=bbdefault
    #SBATCH --mail-type=ALL 

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
    
    #SBATCH --ntasks=5
    #SBATCH --time=3-00
    #SBATCH --qos=bbdefault
    #SBATCH --account=catonim-epi-switch
    #SBATCH --mail-type=ALL 
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
    #SBATCH --ntasks=1
    #SBATCH --time=15:00
    #SBATCH --qos=bbdefault
    #SBATCH --mail-type=ALL 

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
    
    publishDir "data/Alignments/${sampleId}/"
    
    input:
    tuple val(sampleId) , path(reads) 
    path indexed_reference_directory
    
    output:
    path "*.bam"

    script:
    def (trimmedRead1, trimmedRead2) = reads
    """
    #SBATCH --ntasks=5
    #SBATCH --time=3-00
    #SBATCH --qos=bbdefault
    #SBATCH --account=catonim-epi-switch
    #SBATCH --mail-type=ALL 
    set -e

    module purge 
    module load bluebear 
    module load bear-apps/2021b
    module load Bismark/0.24.2-foss-2021b

    mkdir -p "${params.temps}/Alignments/${sampleId}"

    bismark --bowtie2 -p ${params.threads} --parallel ${params.parallelize} \
    --genome ${indexed_reference_directory} -1 ${trimmedRead1} -2 ${trimmedRead2} -o ${params.sampleId}
    """
}




workflow{

    //reads mates from a specified directory.
    paired_reads_ch= Channel.fromFilePairs(params.paired_reads, checkIfExists: true)
    paired_reads_ch.view()
    
    paired_trimmed = TRIM(paired_reads_ch)
    FAST_QC(paired_trimmed) //produces a QC report of trimmed reads. 

   
    
    //called if reference genome is default
    if (params.index_requirement == 0){
        aligned_bam = ALIGNMENT(paired_trimmed, params.reference_genome)
        //add snp calling
    }
    //called if reference genome is custom
    if (params.index_requirement == 1){
        indexed_reference = INDEX(params.reference_genome)
        aligned_bam = ALIGNMENT(paired_reads_trim, indexed_reference)
        //add snp calling
    }

}