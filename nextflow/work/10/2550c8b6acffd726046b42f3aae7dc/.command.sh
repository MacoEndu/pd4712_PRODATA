#!/bin/bash -ue
trimmomatic PE -threads 5         SRR23609085_1.fastq.gz SRR23609085_2.fastq.gz         SRR23609085_R1_trimmed.fastq.gz /dev/null         SRR23609085_R2_trimmed.fastq.gz /dev/null         ILLUMINACLIP:Nextera_transposase_adapters.fasta:2:15:5         LEADING:10 TRAILING:10         SLIDINGWINDOW:4:20 MINLEN:50
