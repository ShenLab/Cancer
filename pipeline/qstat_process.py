import fileinput
import os
import sys
sge_task_id=os.environ["SGE_TASK_ID"]
xm=""
for line in fileinput.input():
  xm=xm+line
from bs4 import BeautifulSoup
s=BeautifulSoup(xm)
if not sge_task_id=="undefined":
  mytask=s.find_all("jat_task_number", text=sge_task_id)
  if len(mytask)==0:
    sys.exit()
  s=mytask[0].parent
if len(s.find_all("ua_name", text="mem"))==0:
  sys.exit()
mem=s.find_all("ua_name", text="mem")[0].find_next_sibling("ua_value").string
cpu=s.find_all("ua_name", text="cpu")[0].find_next_sibling("ua_value").string
vmem=s.find_all("ua_name", text="vmem")[0].find_next_sibling("ua_value").string
maxvmem=s.find_all("ua_name", text="maxvmem")[0].find_next_sibling("ua_value").string
start_time=s.find_all("jat_start_time")[0].string
import time
current_time=int(round(time.time()))
print str(start_time) + "\t" + str(current_time) + "\t" + str(cpu) + "\t" + str(mem) + "\t" + str(vmem) + "\t" + str(maxvmem)
