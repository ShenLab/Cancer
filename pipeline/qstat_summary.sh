#!/bin/bash
#$ -cwd


source ../Test/venv/bin/activate
#nannyjobname=$JOB_NAME
#jobname=$(echo $JOB_NAME | sed 's/_nanny//')
jobname=$JOB_NAME
if [ "$SGE_TASK_ID" != "undefined" ]
then
  usage=Usage/$jobname$SGE_TASK_ID.usage.txt
else
  usage=Usage/$jobname.usage.txt
fi
echo -e 'start_time\tcurrent_time\tcpu\tmem\tvmem\tmaxvmem' > $usage
for i in `seq 1 10000`;
do
   qstat -xml -j $jobname | python qstat_process.py >> $usage
   sleep 30
done
