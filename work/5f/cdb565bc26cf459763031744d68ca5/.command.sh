#!/bin/bash -ue
mkdir -p "/home/marcello/Hazexplorer/data/trimmed//A3_9319"

# Trim paired sequences using fastp (approximately 45 seconds)
fastp -i "A3_9319_1.fq.gz" -I "A3_9319_2.fq.gz"     -o "A3_9319_trimmed_1.fastq.gz"     -O "A3_9319_trimmed_2.fastq.gz""
