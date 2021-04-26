#create a working directory named transcriptome and link the raw sequencing files .fastq.gz
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581
mkdir transcriptome
mkdir transcriptome/DATA

#Sym-link the .fastq.gz files located in
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/
for i in /proj/sens2019581/delivery04273/INBOX/P18362/P18362_131/02-FASTQ/210122_A00187_0419_AHNKKTDSXY/*
do ln -s $i   #创建数据链接 ln
done

#####FastQC: quality check of the raw sequencing reads######
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome
mkdir fastqc
cd fastqc

module load bioinfo-tools 
module load FastQC

for i in /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/DATA/* 
do 
fastqc $i -o /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/fastqc/ 
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
cd /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index
module load bioinfo-tools 
module load star
#建立index#
star --runMode genomeGenerate --runThreadN 6 --genomeDir /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/index --genomeFastaFiles /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/reference/Homo_sapiens.GRCh38.dna.alt.fa --sjdbGTFfile /proj/sens2019581/nobackup/wharf/kangwang/kangwang-sens2019581/transcriptome/reference/Homo_sapiens.GRCh38.103.gtf




#########################
#########.sh########
#########################
touch index.sh
vim index.sh ###进入编辑页面

#!/bin/bash
#construct index for reference









