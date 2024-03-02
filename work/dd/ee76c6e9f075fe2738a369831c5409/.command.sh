#!/bin/bash -ue
mkdir -p /home/marcello/Hazexplorer/results/QC/
fastqc *{1,2}.fq.gz  --threads 4   --quiet true   --output /home/marcello/Hazexplorer/results/
