def trim_qc_process(read1, output, nextflow_trimQC,read2=False):
    #Creates the QC and trimming process in nextflow using single end reads
    if read2 == False:
        print("process QC{",file=nextflow_trimQC)
        print(" output:",file=nextflow_trimQC)
        print(f" path '{output}'",file=nextflow_trimQC)
        print(" script:",file=nextflow_trimQC)
        print(' """',file=nextflow_trimQC)
        print(" insert working script ",file=nextflow_trimQC) ##add script 
        print(' """',file=nextflow_trimQC)
        print("}")

    #Creates the QC and trimming process in nextflow using paired ends reads
    elif read2 != False: 
        print("process QC{",file=nextflow_trimQC)
        print(" output:",file=nextflow_trimQC)
        print(f" path '{output}'",file=nextflow_trimQC)
        print(" script:",file=nextflow_trimQC)
        print(' """',file=nextflow_trimQC)
        print(" insert working script ",file=nextflow_trimQC) ##add script 
        print(' """',file=nextflow_trimQC)
        print("}") 
     
    else: 
        return FileExistsError 
