#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609077_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609077_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609077_variants.vcf > SRR23609077_filtered_variants.vcf
