#!/bin/bash -ue
mkdir -p null/QC/
fastqc *{1,2}.fq.gz  --threads 4   --quiet true
