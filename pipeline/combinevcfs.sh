#!/bin/bash

prefix=$1
numchunks=$2

for i in `seq 1 $numchunks`;
do
  bgzip $prefix.$i.vcf
  tabix -p vcf $prefix.$i.vcf.gz
done
vcf-concat $prefix.*.vcf.gz > $prefix.vcf
mv $prefix.*.vcf.* Temp/

bgzip $prefix.vcf
tabix -p vcf $prefix.vcf.gz
vcf-sort $prefix.vcf.gz > $prefix.vcf

cat $prefix.vcf | bcftools view -f PASS > $prefix.pass.vcf
bgzip $prefix.pass.vcf
tabix -p vcf $prefix.pass.vcf.gz
mv $prefix.vcf* Temp/

#cp /ifs/scratch/c2b2/ngs_lab/db2175/Projects/PersonalizedCancer/FullPipeline/cancer-dream-syn3/input/synthetic_challenge_set3_tumor_20pctmasked_truth.vcf.gz ground.truth.vcf.gz
#tabix -p vcf ground.truth.vcf.gz
#tabix -B ground.truth.vcf.gz /ifs/scratch/c2b2/ngs_lab/db2175/Projects/PersonalizedCancer/FullPipeline/cancer-dream-syn3/input/NGv3.bed | vcftools --vcf - --remove-indels --recode --recode-INFO-all --out ground.truth.masked.vcf
#tabix -B all.filtered.vcf.gz /ifs/scratch/c2b2/ngs_lab/db2175/Projects/PersonalizedCancer/FullPipeline/cancer-dream-syn3/input/NGv3.bed | vcftools --vcf - --remove-indels --recode --recode-INFO-all --out all.filtered.masked.vcf
#bgzip all.filtered.masked.vcf.recode.vcf
#tabix -p vcf all.filtered.masked.vcf.recode.vcf.gz
#bgzip ground.truth.masked.vcf.recode.vcf
#tabix -p vcf ground.truth.masked.vcf.recode.vcf.gz
#vcf-compare all.filtered.masked.vcf.recode.vcf.gz ground.truth.masked.vcf.recode.vcf.gz
