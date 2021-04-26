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
