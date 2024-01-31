## :leaves: Documentation for each file :leaves:

1) **Reads_quality.sh**: carrys out quality control and trimming of reads passed as arguments. 

3) **Reads_director.sh**: orchestrates running of quality control and trimming by launching multiple jobs using extracted reads names. 

4) **Bismark_align.sh**: carrys out a sigle genome alignment using Bismark. The reference genome, ordered mates dir, mate1 file, mate2 file are all parameters that need to be passed for this two work. 

5) **BS_director.sh**: is a multi-faced scritpts that coordinates the creationg of reads mates, followed by launching alignment jobs. Other script required is Bismark_align.sh. 

