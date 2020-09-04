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

params.resultsDir = 'results/gatk'
params.saveMode = 'copy'
params.filePattern = "./*_{R1,R2}.fastq.gz"

params.refFasta = "NC000962_3.fasta"

Channel.fromFilePairs(params.filePattern)
        .set { ch_in_gatk }

Channel.value("$workflow.launchDir/$params.refFasta")
        .set { ch_refFasta }

/*
#==============================================
PROCESS
#==============================================
*/

process PROCESS {
    publishDir params.resultsDir, mode: params.saveMode
    container 'FIXME'


    input:
    set genomeFileName, file(genomeReads) from ch_in_PROCESS

    output:
    path FIXME into ch_out_PROCESS


    script:
    genomeName = genomeFileName.toString().split("\\_")[0]

    """
    CLI PROCESS
    """
}


/*
#==============================================
# extra
#==============================================
*/
