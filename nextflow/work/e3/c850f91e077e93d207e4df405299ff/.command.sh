#!/bin/bash -ue
STAR --runMode alignReads         --genomeDir star_index         --readFilesIn SRR23609078_R1_trimmed.fastq.gz SRR23609078_R2_trimmed.fastq.gz         --readFilesCommand zcat         --outFileNamePrefix SRR23609078_         --outSAMtype BAM SortedByCoordinate         --runThreadN 5         --limitBAMsortRAM 2000000000
