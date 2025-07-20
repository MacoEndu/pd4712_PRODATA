#!/bin/bash -ue
trimmomatic PE -threads 5         SRR23609077_1.fastq.gz SRR23609077_2.fastq.gz         SRR23609077_R1_trimmed.fastq.gz /dev/null         SRR23609077_R2_trimmed.fastq.gz /dev/null         ILLUMINACLIP:Nextera_transposase_adapters.fasta:2:15:5         LEADING:10 TRAILING:10         SLIDINGWINDOW:4:20 MINLEN:50
