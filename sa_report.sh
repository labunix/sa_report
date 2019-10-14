#!/bin/bash
# dpkg -l sysstat
#
# IDLE=8
# KBMEMFREE=2
# KBMEMUSED=3
#
# Yesterday,Average CPU(idle all),MEM(kbmemfree),MEM(kbmemused)
# example output
# 2019/10/13,76.43,545149,2325499

dpkg -l sysstat | grep ^ii >/dev/null && \
  echo -e "-u 8\n-r 2\n-r 3" | \
  awk -v yesterday=$(date -d "yesterday" '+%d') \
    '{print "echo -n $(env LANG=C sar",$1,"-f /var/log/sysstat/sa"yesterday" | awk \047/Average/{print $"$2"}\047);echo -n ,"}' | \
  sh | awk -v yesterday=$(date -d "yesterday" '+%Y/%m/%d') '{gsub(",$","",$0);print yesterday","$0}'

