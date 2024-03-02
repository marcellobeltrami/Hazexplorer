#!/bin/bash -ue
mkdir -p "null/Trimmed/Sample 1/"

# Trim paired sequences using fastp (approximately 45 seconds)
fastp -i "input.1" -I "input.2" -o "null/Trimmed/Sample 1/trimmed_input.1" -O "null/Trimmed/Sample 1/trimmed_input.2"
