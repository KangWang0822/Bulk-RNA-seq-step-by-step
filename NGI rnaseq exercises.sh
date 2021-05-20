###########construct dirctory################
cd /proj/g2021013/nobackup/kangwang/rnaseq
mkdir 1_raw 2_fastqc 3_mapping 4_qualimap 5_dge 6_multiqc reference scripts funannot plots
cd reference
mkdir mouse_chr19_hisat2
###############link to raw data#########
cd /proj/g2021013/nobackup/kangwang/rnaseq/1_raw
ln -s /sw/courses/ngsintro/rnaseq/main/1_raw/*.gz .
ls -l
#################FastQC##################
cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts

cat >fastqc.sh

#!/bin/bash
cd /proj/g2021013/nobackup/kangwang/rnaseq/2_fastqc
module load bioinfo-tools
module load FastQC/0.11.8

for i in ../1_raw/*.gz
do
    echo "Running $i ..."
    fastqc -o . "$i"
done

sh fastqc.sh
firefox ../2_fastqc/.html &
###########Mapping reads using HISAT2##############
cd /proj/g2021013/nobackup/kangwang/rnaseq/reference/
#download genome and annotation
wget ftp://ftp.ensembl.org/pub/release-99/fasta/mus_musculus/dna/Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
wget ftp://ftp.ensembl.org/pub/release-99/gtf/mus_musculus/Mus_musculus.GRCm38.99.gtf.gz
gunzip Mus_musculus.GRCm38.dna.chromosome.19.fa.gz
gunzip Mus_musculus.GRCm38.99.gtf.gz
#####Build index
cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts

cat >hisat2_index.sh

#!/bin/bash
# load module
module load bioinfo-tools
module load HISAT2/2.1.0
cd /proj/g2021013/nobackup/kangwang/rnaseq/reference
hisat2-build \
  -p 1 \
  Mus_musculus.GRCm38.dna.chromosome.19.fa \
  mouse_chr19_hisat2/mouse_chr19_hisat2

#######Map reads
cd /proj/g2021013/nobackup/kangwang/rnaseq/3_mapping
ln -s ../1_raw/* .

#hisat2 \
#-p 1 \
#-x ../reference/mouse_chr19_hisat2/mouse_chr19_hisat2 \       #-x denotes the full path (with prefix) to the aligner index we built in the previous step
#--summary-file "SRR3222409-19.summary" \
#-1 SRR3222409-19_1.fq.gz \
#-2 SRR3222409-19_2.fq.gz \
#-S SRR3222409-19.sam





