#!/bin/bash -ue
bcftools mpileup -f SARS-Cov2_reference_genome.fasta SRR23609082_Aligned.sortedByCoord.out.bam |     bcftools call -mv -v --ploidy 1 -o SRR23609082_variants.vcf

bcftools filter -i 'QUAL>=20 && DP>=10' SRR23609082_variants.vcf > SRR23609082_filtered_variants.vcf
