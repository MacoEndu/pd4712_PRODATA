#!/bin/bash -ue
for vcf in SRR23609079_filtered_variants.vcf SRR23609081_filtered_variants.vcf SRR23609085_filtered_variants.vcf SRR23609077_filtered_variants.vcf SRR23609083_filtered_variants.vcf SRR23609078_filtered_variants.vcf SRR23609080_filtered_variants.vcf SRR23609084_filtered_variants.vcf SRR23609082_filtered_variants.vcf SRR23609086_filtered_variants.vcf; do
    bgzip -c "$vcf" > "$vcf.gz"
    bcftools index "$vcf.gz"
done

bcftools merge -m none -0         *_filtered_variants.vcf.gz         -o merged_filtered_variants.vcf -O v
