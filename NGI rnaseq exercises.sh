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

cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts
cat >hisat2_align.sh

#!/bin/bash
module load bioinfo-tools
module load HISAT2/2.1.0
module load samtools/1.8
# get output filename prefix
prefix=$( basename $1 | sed -E 's/_.+$//' )
hisat2 \
-p 1 \
-x ../reference/mouse_chr19_hisat2/mouse_chr19_hisat2 \
--summary-file "${prefix}.summary" \
-1 $1 \
-2 $2 | samtools sort -O BAM > "${prefix}.bam"

 
cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts
cat >hisat2_align_batch.sh

## find only files for read 1 and extract the sample name
lines=$(find *_1.fq.gz | sed "s/_1.fq.gz//")
for i in ${lines}
do
  ## use the sample name and add suffix (_1.fq.gz or _2.fq.gz)
  echo "Mapping ${i}_1.fq.gz and ${i}_2.fq.gz ..."
  bash ../scripts/hisat2_align.sh ${i}_1.fq.gz ${i}_2.fq.gz
done

cd /proj/g2021013/nobackup/kangwang/rnaseq/3_mapping
bash ../scripts/hisat2_align_batch.sh

#Index all BAM files#
module load samtools/1.8
for i in *.bam
  do
    echo "Indexing $i ..."
    samtools index $i
  done
  
######Post-alignment QC using QualiMap########
cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts
cat >qualimap.sh

#!/bin/bash
# load modules
module load bioinfo-tools
module load QualiMap/2.2.1
# get output filename prefix
prefix=$( basename "$1" .bam)
unset DISPLAY
qualimap rnaseq -pe \
  -bam $1 \
  -gtf "../reference/Mus_musculus.GRCm38.99-19.gtf" \
  -outdir "../4_qualimap/${prefix}/" \
  -outfile "$prefix" \
  -outformat "HTML" \
  --java-mem-size=6G >& "${prefix}-qualimap.log"

cat >qualimap_batch.sh
for i in ../3_mapping/*.bam
do
    echo "Running QualiMap on $i ..."
    bash ../scripts/qualimap.sh $i
done

cd /proj/g2021013/nobackup/kangwang/rnaseq/4_qualimap
sh qualimap.sh
####Counting mapped reads using featureCounts########
cd /proj/g2021013/nobackup/kangwang/rnaseq/scripts
cat >featurecounts.sh

#!/bin/bash
# load modules
module load bioinfo-tools
module load subread/2.0.0
featureCounts \
  -a "../reference/Mus_musculus.GRCm38.99.gtf" \
  -o "counts.txt" \
  -F "GTF" \
  -t "exon" \
  -g "gene_id" \
  -p \
  -s 0 \
  -T 1 \
  ../3_mapping/*.bam
  
cd /proj/g2021013/nobackup/kangwang/rnaseq/5_dge
bash ../scripts/featurecounts.sh

#########Combined QC report using MultiQC#############
cd /proj/g2021013/nobackup/kangwang/rnaseq/6_multiqc
module load bioinfo-tools
module load MultiQC/1.8
multiqc --interactive ../
#登录本地终端#
scp kangwang@rackham.uppmax.uu.se:/proj/g2021013/nobackup/kangwang/rnaseq/6_multiqc/multiqc_report.html ./
