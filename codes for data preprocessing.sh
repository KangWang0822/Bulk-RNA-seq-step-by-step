######Pipeline Next-flow#####
nextflow run nf-core/rnaseq -profile uppmax



#create a working directory named transcriptome and link the raw sequencing files .fastq.gz
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581
mkdir transcriptome
mkdir transcriptome/DATA

#Sym-link the .fastq.gz files located in
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/

for i in
for i in /proj/sens2019581/delivery04273/INBOX/P18362/P18362_131/02-FASTQ/210122_A00187_0419_AHNKKTDSXY/*
do ln -s $i   #创建数据链接 ln
done

#####FastQC: quality check of the raw sequencing reads######
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome
mkdir fastqc
cd fastqc

module load bioinfo-tools 
module load FastQC

for i in /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/* do fastqc $i -o /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/fastqc/ 
done

###########Accessing reference genome and genome annotation file########
mkdir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/reference
####Transfer reference files (.fastq and .gtf ) http://www.ensembl.org/info/data/ftp/index.html######
sftp -q kangwang-sens2019581@bianca-sftp.uppmax.uu.se  ###本地终端键入+密码
cd kangwang-sens2019581
lls ###本地文件
put Homo_sapiens.GRCh38.dna.alt.fa.gz  #上传
put Homo_sapiens.GRCh38.103.gtf.gz  #上传
ls  ###Bianca文
cd kangwang-sens2019581/transcriptome/fastqc
mget *.html          #下载fastaq结果
#######把注释文件放入 reference#### 
gzip -d *gz   #解压缩

############Index#############
mkdir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index
#########################
#########index.sh########
#########################
touch index.sh
vim index.sh ###进入编辑页面 
#参考基因组见Bianca的目录里 /sw/data/igenomes/Homo_sapiens/..

#!/bin/bash -l
#SBATCH -A sens2019581
#SBATCH -p node
#SBATCH -n 32
#SBATCH -t 24:00:00
#SBATCH -J star

cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index
module load bioinfo-tools 
module load star
STAR --runThreadN 6 \
--runMode genomeGenerate \
--genomeDir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index \
--genomeFastaFiles /sw/data/igenomes/Homo_sapiens/Ensembl/GRCh37/Sequence/WholeGenomeFasta/genome.fa \
--sjdbGTFfile /sw/data/igenomes/Homo_sapiens/Ensembl/GRCh37/Annotation/Genes/genes.gtf \
--sjdbOverhang 99

#####1.要退出插入模式回到普通模式，按下键盘上的退出键（ESC键);2.要进入命令行模式，在普通模式下按下冒号键;3.wq:将缓冲区数据保存到文件中并退出
sbatch /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index/index.sh

#############################################################
#####folders to save the mapping results for the sample######
#############################################################
mkdir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star
mkdir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star/P131
###
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star
touch mapping.sh
vim mapping.sh ###进入编辑页面 

#!/bin/bash -l
#SBATCH -A sens2019581
#SBATCH -p core
#SBATCH -n 6
#SBATCH -t 24:00:00
#SBATCH -J star
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star/P131
module load bioinfo-tools 
module load star

STAR --runThreadN 6 \ 
--genomeDir /sw/data/igenomes/Homo_sapiens/UCSC/hg38/Sequence/STARIndex \
--readFilesIn /proj/sens2019581/delivery04273/INBOX/P18362/P18362_131/02-FASTQ/210122_A00187_0419_AHNKKTDSXY/P18362_131_S31_L002_R1_001.fastq.gz /proj/sens2019581/delivery04273/INBOX/P18362/P18362_131/02-FASTQ/210122_A00187_0419_AHNKKTDSXY/P18362_131_S31_L002_R2_001.fastq.gz
--readFilesCommand gunzip -c 
--outFileNamePrefix /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star/P131/P131_
--outSAMtype BAM SortedByCoordinate \
--outSAMunmapped Within \
--outSAMattributes Standard
#########################
#########################
--readFilesIn /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/P18362_131_S31_L002_R1_001.fastq.gz /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/P18362_131_S31_L002_R2_001.fastq.gz \

chmod 777 /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/*.fastq.gz
cat >mapping.sh
#!/bin/bash -l
#SBATCH -A sens2019581
#SBATCH -p core 
#SBATCH -n 6
#SBATCH -t 24:00:00
#SBATCH -J star
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star/P131
module load bioinfo-tools 
module load star

STAR --runThreadN 6 \
--runMode alignReads
--genomeDir /sw/data/igenomes/Homo_sapiens/UCSC/hg38/Sequence/STARIndex \
--readFilesIn /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/P18362_131_S31_L002_R1_001.fastq.gz /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/P18362_131_S31_L002_R2_001.fastq.gz \ 
--readFilesCommand zcat
--outFileNamePrefix /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/star/P131/P131_
--outSAMtype BAM SortedByCoordinate \
--outSAMunmapped Within \
--outSAMattributes Standard






