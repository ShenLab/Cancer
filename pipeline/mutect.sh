#!/bin/bash
#$ -cwd -l mem=5G,time=8:: -e Logs -o Logs

endtimefunc () {
  echo -e "\t`date +'%s'`" >> $1
}

normalbam=$1
tumorbam=$2
prefix=$3
partitions=$4
REF=$5
./qstat_summary.sh &
# qsub -N ${JOB_NAME}_nanny -cwd -l mem=1G,time=48:: qstat_summary.sh 
# use at least 8G so bwa mem can open index

TMP=/ifs/scratch/c2b2/ngs_lab/db2175/TEMP
timing=Usage/${JOB_NAME}${SGE_TASK_ID}.timing.txt
echo -e "job\tsample\tstart\tend" > $timing

interval=$(head -$SGE_TASK_ID $partitions | tail -1)

MUTECTJAR=/ifs/data/c2b2/ngs_lab/ngs/usr/muTect-1.1.4-bin/muTect-1.1.4.jar
COSMIC=/ifs/data/c2b2/ngs_lab/ngs/resources/bwa_samtools_gatk_DB/b37_cosmic_v54_120711.vcf
DBSNP=/ifs/data/c2b2/ngs_lab/ngs/resources/bwa_samtools_gatk_DB/dbsnp_132_b37.leftAligned.vcf
echo -n -e "mutect\t$SGE_TASK_ID\t`date +'%s'`" >> $timing 
# doesn't work with jdk1.7 
/ifs/data/c2b2/ngs_lab/ngs/usr/jdk1.6.0_11/bin/java -Xmx2g -jar -Djava.io.tmpdir=$TMP $MUTECTJAR --analysis_type MuTect --reference_sequence $REF --cosmic $COSMIC --dbsnp $DBSNP -L $interval --input_file:normal $normalbam --input_file:tumor $tumorbam --vcf $prefix.$SGE_TASK_ID.vcf --out Temp/$prefix.mutect.$SGE_TASK_ID.out 
endtimefunc $timing
# echo -e "\t`date +'%s'`" >> $timing  
