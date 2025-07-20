#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609080_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609080_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609080_variants.vcf > SRR23609080_filtered_variants.vcf
