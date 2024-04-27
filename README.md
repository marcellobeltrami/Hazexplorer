# Hazexplorer :deciduous_tree: :compass:

![alt text](./logo/Hazexplorer.png)

This tool aims at analyzes methylation states from bisulphite sequencing data. This pipeline will take as input raw reads of Bisulphite Sequencing and output SNP calls.
Tool testing was done on Hazel dataset, although changing reference genome will allow to adapt pipeline to any plant genome.


### Pre-requisites
To run the HAZEXPLORER pipeline, follow these steps:

Dependencies:

    Nextflow (version 22.04.0)
    Slurm job scheduler (optional, for HPC execution, comment out in .config file if not needed.)
    Bismark (version 0.24.2)
    FastQC (version 0.11.9)
    Fastp (version 0.23.2)

If tools do not meet exact requirements, pipeline might behave unexpectedly. 

### Quick-start

1. Install Nextflow: Follow the instructions [here](https://www.nextflow.io/docs/latest/getstarted.html) to install Nextflow.

2. Clone the repository:
    ```bash
    git clone https://github.com/marcellobeltrami/Hazexplorer
    ```

3. Navigate to the cloned directory:
    ```bash
    cd Hazexplorer
    ```

4. Execute the pipeline:
    ```bash
    sbatch nextflow run main_hazex_v.2.nf --paired_reads='<path to paire reads, follow this example format: ./data/reads/*{1,2}.fq.gz>' --reference_genome='<full_path_to_reference_genome>' --reference_name='reference_name' --index_requirement=<0_or_1>
    ```


### Architecture
Directories structure are as follows:
- **bin**: contains custom scripts for alignment, SNP calling, and others. Although these are not directly used by slurm, we decided to provide them for free use.    

- **data**: default directory where reads for data for analysis will be looked for. 

- **logs**: as this tool is meant to be used with slurm scheduler, logs from slurm jobs will be stored here.

- **work**: will be generate at Nextflow runtime and will contain temporary files and other files generated during analysis. 

