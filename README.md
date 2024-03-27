# Hazexplorer :deciduous_tree: :compass:
![alt text](./logo/Hazexplorer.png)

This tool aims at analyzes methylation states from bisulphite sequencing data. This pipeline will take as input raw reads of Bisulphite Sequencing and output SNP calls.
Tool testing was done on Hazel dataset, although changing reference genome will allow to adapt pipeline to any plant genome.  

Directories are as follows:
- **bin**: contains custom scripts for alignment, SNP calling, and others 

- **data**: contains data for analysis. 

- **logs**: as this tool is meant to be used with slurm scheduler, logs from slurm jobs will be stored here.

- **temps**: will contain temporary files and other files generated during analysis. 

