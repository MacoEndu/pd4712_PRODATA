#!/bin/bash -ue
STAR --runMode genomeGenerate         --genomeDir ./star_index         --genomeFastaFiles SARS-Cov2_reference_genome.fasta         --genomeSAindexNbases 6         --runThreadN 5
