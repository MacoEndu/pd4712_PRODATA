nextflow.enable.dsl = 2

// Parametry pipeline
params.input = null
params.ref_genome = "./reference_genome"
params.outdir = './results'
params.threads = 1
params.multiqc_title = ''
params.adapters = "/home/macoe/PRODATA_project/nexflow/adapters/Nextera_transposase_adapters.fasta"

// Kontrola jakości FASTQ
process FASTQC {
    tag "$meta.id"
    publishDir "$params.outdir/fastqc", mode: 'copy'

    input:
    tuple val(meta), path(fastq_file)

    output:
    tuple val(meta), path("*_fastqc.zip"), emit: fastqc_zip
    path("*_fastqc.html"), emit: fastqc_html

    script:
    """
    fastqc ${fastq_file} -t ${params.threads}
    """
}

// Podsumowanie wyników FastQC
process MULTIQC {
    tag "MultiQC"
    publishDir "$params.outdir/multiqc", mode: 'copy'

    input:
    path fastqc_zip

    output:
    path '*multiqc_report.html', emit: multiqc_report
    path '*multiqc_report_data', type: 'dir', emit: multiqc_data

    script:
    """
    multiqc . --title \"${params.multiqc_title}\"
    """
}

// Przycinanie adapterów i filtrowanie jakości
process TRIMMOMATIC {
    tag "$meta.id"
    publishDir "$params.outdir/trimmed", mode: 'copy'

    input:
    tuple val(meta), path(read1), path(read2)
    each path(adapter_file)

    output:
    tuple val(meta), path("*_trimmed.fastq.gz"), emit: trimmed_fastq

    script:
    """
    trimmomatic PE -threads ${params.threads} \
        ${read1} ${read2} \
        ${meta.id}_R1_trimmed.fastq.gz /dev/null \
        ${meta.id}_R2_trimmed.fastq.gz /dev/null \
        ILLUMINACLIP:${adapter_file}:2:15:5 \
        LEADING:10 TRAILING:10 \
        SLIDINGWINDOW:4:20 MINLEN:50
    """
}

// Budowa indeksu genomu referencyjnego
process STAR_INDEX {
    tag "STAR Index"
    publishDir "${params.outdir}/star_index", mode: 'copy'

    input:
    path(genome_fasta)

    output:
    path "star_index", emit: star_index

    script:
    """
    STAR --runMode genomeGenerate \
        --genomeDir ./star_index \
        --genomeFastaFiles ${genome_fasta} \
        --genomeSAindexNbases 6 \
        --runThreadN ${params.threads}
    """
}

// Mapowanie odczytów do genomu referencyjnego
process STAR_ALIGN {
    tag "$meta.id"
    publishDir "$params.outdir/mapped", mode: 'copy'

    input:
    tuple val(meta), path(read1), path(read2), path(star_index)

    output:
    tuple val(meta), path("*Aligned.sortedByCoord.out.bam"), emit: bam_aligned

    script:
    """
    STAR --runMode alignReads \
        --genomeDir ${star_index} \
        --readFilesIn ${read1} ${read2} \
        --readFilesCommand zcat \
        --outFileNamePrefix ${meta.id}_ \
        --outSAMtype BAM SortedByCoordinate \
        --runThreadN ${params.threads} \
        --limitBAMsortRAM 2000000000
    """
}

// Indeksowanie plików BAM
process SAMTOOLS_INDEX {
    tag "$meta.id"
    publishDir "$params.outdir/mapped", mode: 'copy'

    input:
    tuple val(meta), path(bam_file)

    output:
    tuple val(meta), path("*.bai"), emit: bai_file

    script:
    """
    samtools index -@ ${params.threads} ${bam_file}
    """
}

// Identyfikacja wariantów genetycznych
process VARIANT_CALLING {
    tag "$meta.id"
    publishDir "$params.outdir/variants", mode: 'copy'

    input:
    tuple val(meta), path(bam_file), path(ref_genome)

    output:
    tuple val(meta), path("*_variants.vcf"), emit: vcf_file
    tuple val(meta), path("*_filtered_variants.vcf"), emit: filtered_vcf

    script:
    """
    bcftools mpileup -f ${ref_genome} ${bam_file} | \
    bcftools call -mv -v --ploidy 1 -o ${meta.id}_variants.vcf
   
    bcftools filter -i 'QUAL>=20 && DP>=10' ${meta.id}_variants.vcf > ${meta.id}_filtered_variants.vcf
    """
}

// Łączenie plików VCF ze wszystkich próbek
process MERGE_VCF {
    tag "Merge VCF"
    publishDir "$params.outdir/variants", mode: 'copy'

    input:
    path vcf_files

    output:
    path "merged_filtered_variants.vcf", emit: merged_vcf

    script:
    """
    for vcf in ${vcf_files}; do
        bgzip -c "\$vcf" > "\$vcf.gz"
        bcftools index "\$vcf.gz"
    done
   
    bcftools merge -m none -0 \
        *_filtered_variants.vcf.gz \
        -o merged_filtered_variants.vcf -O v
    """
}

workflow {
    // Informacje o parametrach uruchomienia
    log.info """\
    ===========================================
    ROZPOCZYNAM WORKFLOW NGS
    ===========================================
    input: ${params.input}
    outdir: ${params.outdir}
    ref_genome: ${params.ref_genome}
    Analysis threads: ${params.threads}
    multiqc_title: ${params.multiqc_title}
    params.adapters: ${params.adapters}
    """
    .stripIndent()

    if (!params.input) {
        log.error "No input files provided. Please specify input files using the --input parameter."
        exit 1
    }

    // Przygotowanie kanału danych wejściowych
    input_ch = Channel
        .fromFilePairs("${params.input}_{1,2}.fastq.gz")
        .map { sample_id, reads ->
            def meta = [ id: sample_id ]
            [meta, reads[0], reads[1]]
        }

    // Przycinanie adapterów
    adapter_ch = Channel.fromPath(params.adapters, checkIfExists: true)
    TRIMMOMATIC(input_ch, adapter_ch.collect())
    trimmed_ch = TRIMMOMATIC.out.trimmed_fastq

    // Kontrola jakości przyciętych odczytów
    FASTQC(trimmed_ch)
    zip_ch = FASTQC.out.fastqc_zip.collect{it[1]}
    MULTIQC(zip_ch)

    // Budowa indeksu genomu
    ref_genome_ch = Channel.fromPath("${params.ref_genome}/*.fasta", checkIfExists: true)
    star_index_ch = STAR_INDEX(ref_genome_ch)

    // Przygotowanie danych do mapowania
    trimmed_flat = TRIMMOMATIC.out.trimmed_fastq
        .map { meta, files ->
            tuple(meta, files[0], files[1])
        }
    star_align_input = trimmed_flat
        .combine(star_index_ch)
        .map { meta, read1, read2, index ->
            tuple(meta, read1, read2, index)
        }
    
    // Mapowanie i indeksowanie
    STAR_ALIGN(star_align_input)
    SAMTOOLS_INDEX(STAR_ALIGN.out.bam_aligned)
    
    // Identyfikacja wariantów
    variant_input = STAR_ALIGN.out.bam_aligned
        .combine(ref_genome_ch)
    VARIANT_CALLING(variant_input)

    // Łączenie wyników z wszystkich próbek
    filtered_vcf_files = VARIANT_CALLING.out.filtered_vcf
        .map { meta, vcf -> vcf }
        .collect()
    MERGE_VCF(filtered_vcf_files)
}
