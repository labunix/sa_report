#!/bin/bash
# 1 days ago

for list in CPU.tmp MEM.tmp DISK.tmp JOIN1.tmp JOIN2.tmp;do
  if [ -f "$list" ];then
    echo "Error,Found $list" >&2
    exit 1
  fi
done

TARGET="/var/log/sysstat/sa`date '+%d' --date '1 days ago'`"
MYDAYS="`date '+%Y/%m/%d' --date '1 days ago'`"
LOGDAY="`date '+%Y%m%d' --date '1 days ago'`"

# CPU 100-idle %
env LANG=C sar -u -f $TARGET | \
  grep "^[0-9][0-9]\:" | \
  grep -v "START" | \
  sed s/%//g | \
  awk '{if($8=="idle") MSG=$8; else print $1","100-$8} \
        END{print "CPU USED(%)=100-"MSG > "/dev/fd/2"}' > CPU.tmp 

# MEM memused %
env LANG=C sar -r -f $TARGET | \
  grep "^[0-9][0-9]\:" | \
  grep -v "START" | \
  sed s/%//g | \
  awk '{if($4=="memused") MSG=$4; else print $1","$4} \
        END{print "MEM USED(%)="MSG > "/dev/fd/2"}' > MEM.tmp

# Disk I/O wait %
env LANG=C sar -d -f $TARGET | \
  grep "^[0-9][0-9]\:" | \
  grep -v "START" | \
  sed s/%//g | \
  awk '{if($10=="util") MSG=$10; else print $1","$10} \
        END{print "DISK WAIT(%)="MSG > "/dev/fd/2"}' > DISK.tmp

# Network Error Check

env LANG=C netstat -i | \
  grep -v Kernel | \
  awk '{print $1,$5,$6,$9,$10}' | \
  awk '{if($1!="0" && $2!="0" && $3!="0")print}'

if [ -f CPU.tmp ];then
  if [ -f MEM.tmp ];then
    if [ -f DISK.tmp ];then
      join -t, CPU.tmp MEM.tmp > JOIN1.tmp
      join -t, JOIN1.tmp DISK.tmp | sed s%^%"$MYDAYS,"%g | \
      sed s/"\:[0-9][0-9],"/","/g > JOIN2.tmp
      echo "date,Time,CPU,MEM,Disk" | \
      cat - JOIN2.tmp > `hostname -s`_Perf_$LOGDAY.log
      rm -f JOIN[12].tmp DISK.tmp MEM.tmp CPU.tmp
    fi
  fi
fi
unset TARGET MYDAYS LOGDAY list
exit 0
