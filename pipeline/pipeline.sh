#!/bin/bash

# check dependencies exist

endtimefunc () {
  echo -e "\t`date +'%s'`" >> $1
}
mkdir Logs
mkdir Usage
mkdir Temp

job_name=$1
numlines=$2

REF=/ifs/data/c2b2/ngs_lab/ngs/usr/src/bwa-0.7.3/human_b37/human_g1k_v37.fasta
folder=/ifs/scratch/c2b2/ngs_lab/db2175/Projects/PersonalizedCancer/FullPipeline/cancer-dream-syn3/input
normal1=$folder/synthetic_challenge_set3_normal_NGv3_1.fq.gz
normal2=$folder/synthetic_challenge_set3_normal_NGv3_2.fq.gz
tumor1=$folder/synthetic_challenge_set3_tumor_NGv3_1.fq.gz
tumor2=$folder/synthetic_challenge_set3_tumor_NGv3_2.fq.gz


if [ -z "$2" ]
then
  ln -s $normal1 normal1.fq
  ln -s $normal2 normal2.fq
  ln -s $tumor1 tumor1.fq
  ln -s $tumor2 tumor2.fq
else 
  numfqlines=$(($numlines * 4))
  zcat $normal1 | head -$numfqlines > normal1.fq
  zcat $normal2 | head -$numfqlines > normal2.fq
  zcat $tumor1 | head -$numfqlines > tumor1.fq
  zcat $tumor2 | head -$numfqlines > tumor2.fq
fi

if [ ! -f normal.bam.bai ]; then
  qsub -N ${job_name}bwanormal bwa.sh normal1.fq normal2.fq normal $REF
fi
if [ ! -f tumor.bam.bai ]; then
  qsub -N ${job_name}bwatumor bwa.sh tumor1.fq tumor2.fq tumor $REF
fi

qsub -hold_jid ${job_name}bwanormal -N ${job_name}realignnormal realign.sh normal.bam $REF
qsub -hold_jid ${job_name}bwatumor -N ${job_name}realigntumor realign.sh tumor.bam $REF

mutectchunks=5
partitions=mutect_partitions.txt
qsub -N ${job_name}chunk chunk.sh $mutectchunks $partitions

qsub -hold_jid ${job_name}chunk,${job_name}bwanormal,${job_name}bwatumor -N ${job_name}mutect -t 1-$mutectchunks mutect.sh normal.bam tumor.bam paired $partitions $REF

qsub -hold_jid ${job_name}chunk,${job_name}realignnormal,${job_name}realigntumor -N ${job_name}mutectrealign -t 1-$mutectchunks mutect.sh normal.realigned.bam tumor.realigned.bam paired.realigned $partitions $REF

qsub -hold_jid ${job_name}mutect -N ${job_name}combine combinevcfs.sh paired $mutectchunks
qsub -hold_jid ${job_name}mutectrealign -N ${job_name}realign combinevcfs.sh paired.realigned $mutectchunks
