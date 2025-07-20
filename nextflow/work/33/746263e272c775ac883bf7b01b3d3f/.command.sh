#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609083_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609083_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609083_variants.vcf > SRR23609083_filtered_variants.vcf
