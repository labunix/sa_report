#!/bin/bash
if [ $# -lt 1 ];then
  echo "Usage : $0 [ hostname_yyyymmdd_cpuidle.log ]"
  exit 1
fi
FILENAME=$1
echo $FILENAME | grep "\.log\$" || exit 1
OUTFILE=$(echo ${FILENAME} | sed s/"\.log"/"\.png"/)
TITLE="all CPU idle %"

(echo 'set terminal png size 1024,600';
 echo 'set datafile separator ","';
 echo "set output \"${OUTFILE}\""; 
 echo 'set xdata time';
 echo 'set key outside';
 echo 'set timefmt "%H:%M:%S"';
 echo 'set format x "%H:%M"';
 echo 'set yrange [0:100]';
 echo 'plot "'${FILENAME}'" using 1:2 title "'${TITLE}'" with lines'; \
 ) | gnuplot

unset FILENAME
unset OUTFILE
unset TITLE
exit 0
