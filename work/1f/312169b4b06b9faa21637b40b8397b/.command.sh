#!/bin/bash -ue
mkdir -p "null/Trimmed/null/"

# Trim paired sequences using fastp (approximately 45 seconds)
fastp -i "A3_9319_1.fq.gz" -I "A3_9319_2.fq.gz" -o "null/Trimmed/null/trimmed_A3_9319_1.fq.gz" -O "null/Trimmed/null/trimmed_A3_9319_2.fq.gz"
