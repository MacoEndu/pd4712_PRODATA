#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609079_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609079_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609079_variants.vcf > SRR23609079_filtered_variants.vcf
