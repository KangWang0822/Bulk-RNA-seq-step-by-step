# Bulk-RNA-seq-step-by-step

Guided by https://scilifelab.github.io/courses/ngsintro/1805/labs/rnaseq_161129.

1.check the quality of the raw reads with FastQC.
2.map the reads to the reference genome using Star.
3.convert between SAM and BAM files format using Samtools.
4.assess the post-alignment reads quality using QualiMap.
5.count the reads overlapping with genes regions using featureCounts.
6.build statistical model to find DE genes using edgeR from a prepared R script.

# Latest NGI courses for rnaseq

Guided by https://nbisweden.github.io/workshop-ngsintro/2105/lab_rnaseq.html

Main exercise

01 Check the quality of the raw reads with FastQC
02 Map the reads to the reference genome using HISAT2
03 Assess the post-alignment quality using QualiMap
04 Count the reads overlapping with genes using featureCounts
05 Find DE genes using DESeq2 in R
RNA-seq experiment does not necessarily end with a list of DE genes. If you have time after completing the main exercise, try one (or more) of the bonus exercises. The bonus exercises can be run independently of each other, so choose the one that matches your interest. Bonus sections are listed below.

Bonus exercises

01 Functional annotation of DE genes using GO/Reactome databases
02 RNA-Seq figures and plots using R
03 Visualisation of RNA-seq BAM files using IGV genome browser
