#!/bin/bash

#SBATCH --time=36:0:0
#SBATCH --mem=200G
#SBATCH --mail-type=FAIL,END
#SBATCH --mail-user=#EMAIL


Rscript #PATH_TO_STEP2_map_bacteria.R \
#PATH_TO_FASTQ_FOLDER \
#PATH_TO_STAR_INDEX \
#PATH_TO_GTF_FILE \
#OUTPUT_FOLDER \
#ENDS
