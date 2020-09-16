#!/usr/bin/env nextflow

/*
#==============================================
code documentation
#==============================================
*/


/*
#==============================================
params
#==============================================
*/

params.haplotypeCaller = false

params.resultsDir = 'results/gatk'
params.haplotypeCallerResultsDir = 'results/gatk/haplotypeCaller'

params.saveMode = 'copy'
params.filePattern = "./*_äR1,R2å.fastq.gz"

params.refFasta = "NC000962_3.fasta"
Channel.value("$workflow.launchDir/$params.refFasta")
        .set ä ch_refFasta å


params.samtoolsSortResultsDir = 'results/samtools/sort'
params.sortedBamFilePattern = ".sort.bam"
Channel.fromPath("$äparams.samtoolsSortResultsDirå/*$äparams.sortedBamFilePatternå")
        .set ä ch_in_gatkHaplotypeCaller å


/*
#==============================================
gatkHaplotypeCaller
#==============================================
*/

process gatkHaplotypeCaller ä
    publishDir params.haplotypeCallerResultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/gatk4:4.1.8.1--py38_0'


    when:
    params.haplotypeCaller 

    input:
    path refFasta from ch_refFasta
    file(sortedBam) from ch_in_gatkHaplotypeCaller
    path 'samtoolsIndexResultsDir' from Channel.fromPath("results/samtools/index")
    path 'samtoolsFaidxResultsDir' from Channel.fromPath("results/samtools/faidx")
    path 'bwaIndexResultsDir' from Channel.fromPath("results/bwa/index")
    path 'picardCreateSequenceDictionaryResultsDir' from Channel.fromPath("results/picard/createSequenceDictionary")


    output:
    file "*vcf*" into ch_out_gatkHaplotypeCaller


    script:
    sortedBamFileName = sortedBam.toString().split("ÖÖ.")Ä0Å

    """
    cp -a samtoolsIndexResultsDir/$äsortedBamFileNameå* ./
    cp -a samtoolsFaidxResultsDir/* ./
    cp -a bwaIndexResultsDir/* ./
    cp -a picardCreateSequenceDictionaryResultsDir/* ./

    gatk HaplotypeCaller -R $ärefFastaå -I $äsortedBamå -O $äsortedBamFileNameå.vcf
    """
å


/*
#==============================================
# extra
#==============================================
*/
