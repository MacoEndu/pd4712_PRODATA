#!/bin/bash -ue
STAR --runMode alignReads         --genomeDir star_index         --readFilesIn SRR23609082_R1_trimmed.fastq.gz SRR23609082_R2_trimmed.fastq.gz         --readFilesCommand zcat         --outFileNamePrefix SRR23609082_         --outSAMtype BAM SortedByCoordinate         --runThreadN 5         --limitBAMsortRAM 2000000000
