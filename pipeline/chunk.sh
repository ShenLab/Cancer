#!/bin/bash
#$ -cwd -l mem=5G,time=1:: -e Logs -o Logs
mutectchunks=$1
partitions=$2

Rscript chunk.R $mutectchunks $partitions
