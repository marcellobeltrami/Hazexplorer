#!/bin/python


import os
import glob
import subprocess

directory = "/rds/projects/l/lunadiee-epi-virtualmchine/Students/gp_project_MSKD/Hazel_WGBS/X204SC23064008-Z01-F001_01"
extension = ".fq"

# List all files with the specified extension in the directory and subdirectories
files_sorted = sorted(glob.glob(os.path.join(directory, '**', f'*{extension}'), recursive=True))

index = 0
index_1 = 1

list_length = len(files_sorted)

while index < list_length:
    file = files_sorted[index]
    file_1 = files_sorted[index_1]

    # Schedule jobs and provide feedback regarding submission
    # You can replace the following subprocess.call lines with your job submission logic.
    subprocess.run(['sbatch', 'reads_quality.sh', file, file_1])
    
    print(f"{index}: {file} submitted")
    print(f"{index}: {file_1} submitted")

    # Increment the indices
    index += 2
    index_1 += 2
