#!/bin/bash -ue
trimmomatic PE -threads 5         SRR23609081_1.fastq.gz SRR23609081_2.fastq.gz         SRR23609081_R1_trimmed.fastq.gz /dev/null         SRR23609081_R2_trimmed.fastq.gz /dev/null         ILLUMINACLIP:Nextera_transposase_adapters.fasta:2:15:5         LEADING:10 TRAILING:10         SLIDINGWINDOW:4:20 MINLEN:50
