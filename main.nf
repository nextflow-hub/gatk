#!/usr/bin/env nextflow
import java.nio.file.Paths

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
params.markDuplicatesSpark = false

params.resultsDir = 'results/gatk'
params.haplotypeCallerResultsDir = 'results/gatk/haplotypeCaller'
params.markDuplicatesSparkResultsDir = 'results/gatk/markDuplicatesSpark'


params.saveMode = 'copy'
params.filePattern = "./*_{R1,R2}.fastq.gz"

params.refFasta = "NC000962_3.fasta"
Channel.value("$workflow.launchDir/$params.refFasta")
        .set { ch_refFasta }


params.samtoolsSortResultsDir = 'results/samtools/sort'
params.sortedBamFilePattern = ".sort.bam"
Channel.fromPath("${params.samtoolsSortResultsDir}/*${params.sortedBamFilePattern}")
        .set { ch_in_gatkHaplotypeCaller }


params.bwaMemResultsDir = './results/bwa/mem'
params.bamFilePattern = ".bam"
Channel.fromPath("${params.bwaMemResultsDir}/*${params.bamFilePattern}")
        .set { ch_in_markDuplicatesSpark }


/*
#==============================================
HaplotypeCaller
#==============================================
*/

process HaplotypeCaller {
    publishDir params.haplotypeCallerResultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/gatk4:4.1.8.1--py38_0'


    when:
    params.haplotypeCaller 

    input:
    path refFasta from ch_refFasta
    path "samtoolsIndexResultsDir"  from Channel.value(Paths.get("results/samtools/index"))
    path "samtoolsFaidxResultsDir"  from Channel.value(Paths.get("results/samtools/faidx"))
    path "bwaIndexResultsDir" from Channel.value(Paths.get("results/bwa/index"))
    path "picardCreateSequenceDictionaryResultsDir" from Channel.value(Paths.get("results/picard/createSequenceDictionary"))
    file(sortedBam) from ch_in_gatkHaplotypeCaller



    output:
    file "*vcf*" into ch_out_gatkHaplotypeCaller


    script:
    sortedBamFileName = sortedBam.toString().split("\\.")[0]

    """
    cp -a samtoolsIndexResultsDir/${sortedBamFileName}* ./
    cp -a samtoolsFaidxResultsDir/* ./
    cp -a bwaIndexResultsDir/* ./
    cp -a picardCreateSequenceDictionaryResultsDir/* ./

    gatk HaplotypeCaller -R ${refFasta} -I ${sortedBam} -O ${sortedBamFileName}.vcf
    """
}


/*
#==============================================
MarkDuplicatesSpark
#==============================================
*/

process MarkDuplicatesSpark {
    publishDir params.markDuplicatesSparkResultsDir, mode: params.saveMode
    container 'quay.io/biocontainers/gatk4:4.1.8.1--py38_0'


    when:
    params.markDuplicatesSpark 

    input:
    path refFasta from ch_refFasta
    file(samFile) from ch_in_markDuplicatesSpark


    output:
    tuple file "*bam*",
             file "*_metrics.txt"into ch_out_gatkHaplotypeCaller


    script:
    samFileName = samFile.toString().split("\\.")[0]

    """
    gatk MarkDuplicatesSpark -I ${samFile} -M ${samFileName}_dedup_metrics.txt -O ${samFileName}.sort.bam
    """
}




/*
#==============================================
# extra
#==============================================
*/
