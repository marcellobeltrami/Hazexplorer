#!/bin/bash -ue
mkdir -p "null/Trimmed/Sample 1/"

# Trim paired sequences using fastp (approximately 45 seconds)
fastp -i "input.1" -I "A3_9319_1.fq.gz A3_9319_2.fq.gz" -o "null/Trimmed/Sample 1/trimmed_input.1" -O "null/Trimmed/Sample 1/trimmed_A3_9319_1.fq.gz A3_9319_2.fq.gz"
