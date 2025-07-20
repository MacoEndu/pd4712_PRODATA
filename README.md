# Projekt PRODATA - Pipeline NGS do Analizy SARS-CoV-2

![GitHub last commit](https://img.shields.io/github/last-commit/MacoEndu/pd4712_PRODATA)
![GitHub repo size](https://img.shields.io/github/repo-size/MacoEndu/pd4712_PRODATA)
![GitHub language count](https://img.shields.io/github/languages/count/MacoEndu/pd4712_PRODATA)

Kompleksowy projekt zawierający pipeline do analizy danych sekwencjonowania nowej generacji (NGS) dla wirusa SARS-CoV-2. Projekt implementuje dwa równoległe podejścia: **Nextflow** i **Snakemake**, oferując elastyczne rozwiązania do automatycznej analizy genomowej.

## 🧬 Przegląd Projektu

Ten projekt został opracowany w ramach kursu PRODATA i zawiera pełny workflow analizy NGS, od kontroli jakości surowych odczytów po identyfikację i analizę wariantów genetycznych wirusa SARS-CoV-2.

### Główne Komponenty

- **Nextflow Pipeline** - Nowoczesny, skalowalny workflow z konteneryzacją Docker
- **Snakemake Pipeline** - Alternatywny workflow z środowiskami Conda
- **Dane Referencyjne** - Genom referencyjny SARS-CoV-2 Wuhan-Hu-1 (NC_045512.2)
- **Konfiguracje** - Gotowe pliki konfiguracyjne i środowiska

## 📊 Dane Wejściowe

- **Próbka testowa**: Biosample SAMN33344176
- **Genom referencyjny**: SARS-CoV-2 Wuhan-Hu-1 (NC_045512.2)
- **Format danych**: Pliki FASTQ paired-end (Illumina)
- **Adaptery**: Nextera transposase adapters

## 🔧 Wymagania Systemowe
Nextflow (≥21.04)
Snakemake (≥6.0)
Docker

### Oprogramowanie Podstawowe
Python (≥3.8)
Conda/Mamba
Java (≥11)

### 2. Uruchomienie Pipeline Nextflow
 nextflow run nextflow/nextflow_workflow.nf
-c nextflow/nextflow.config
--input "raw/*"
--outdir results
--threads 5'''
--multiqc_title "SARS-CoV-2"
-profile docker  

### 3. Uruchomienie Pipeline Snakemake

```snakemake --cores 8 --use-conda ````
