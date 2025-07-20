#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609085_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609085_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609085_variants.vcf > SRR23609085_filtered_variants.vcf
