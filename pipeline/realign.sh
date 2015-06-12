#!/bin/bash
#$ -cwd -l mem=12G,time=24:: -e Logs -o Logs

endtimefunc () {
  echo -e "\t`date +'%s'`" >> $1
}

bam=$1
REF=$2
./qstat_summary.sh &
# qsub -N ${JOB_NAME}_nanny -cwd -l mem=1G,time=48:: qstat_summary.sh 
# use at least 8G so bwa mem can open index

TMP=/ifs/scratch/c2b2/ngs_lab/db2175/TEMP
GATKJAR=/ifs/data/c2b2/ngs_lab/ngs/usr/GATK-3.1-1/GenomeAnalysisTK.jar
INDELVCF=/ifs/data/c2b2/ngs_lab/ngs/resources/bwa_samtools_gatk_DB/1000G_indels_for_realignment.b37.vcf
MaxReads=20000
timing=Usage/${JOB_NAME}.timing.txt

echo -e "job\tsample\tstart\tend" > $timing
echo -n -e "realign_intervals\t$JOB_NAME\t`date +'%s'`" >> $timing 
# doesn't work with jdk1.7 
JAVA=/nfs/apps/java/1.7.0_25/bin/java
#JAVA=/ifs/data/c2b2/ngs_lab/ngs/usr/jdk1.6.0_11/bin/java
$JAVA -Xmx9g -jar -Djava.io.tmpdir=$TMP $GATKJAR -T RealignerTargetCreator -I $bam -R $REF -known $INDELVCF -o forRealigner.intervals 
endtimefunc $timing
echo -n -e "realign\t$JOB_NAME\t`date +'%s'`" >> $timing 
# doesn't work with jdk1.7 
realignedbam=$(echo $bam | sed 's/bam/realigned.bam/')
$JAVA -Xmx9g -jar -Djava.io.tmpdir=$TMP $GATKJAR -T IndelRealigner -I $bam -R $REF -known $INDELVCF --maxReadsForRealignment $MaxReads -compress 5 -targetIntervals forRealigner.intervals -o $realignedbam
mv forRealigner.intervals Temp/
endtimefunc $timing
echo -n -e "index\t$JOB_NAME\t`date +'%s'`" >> $timing 
# doesn't work with jdk1.7 
samtools index $realignedbam
endtimefunc $timing
# echo -e "\t`date +'%s'`" >> $timing  
