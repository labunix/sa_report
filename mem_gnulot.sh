#!/bin/bash
if [ $# -lt 1 ];then
  echo "Usage $0 [ hostname_yyyymmdd_kbmemfree.log ]"
  exit 1
fi
FILENAME=$1
echo $FILENAME | grep "\.log\$" || exit 1
OUTFILE=$(echo ${FILENAME} | sed s/"\.log"/"\.png"/)
#MAX=`LANG=C free -k | grep ^Mem | awk '{print $2/1024}'`
MAX=1994744
#MAX=4025956
TITLE="KB Mem Free %"

if [ "x${MAX}" == "x" ] ;then
  echo "ERROR: Not found ${MAX}"
  exit 1
fi
awk -F\, '{print $1","($2/'${MAX}')*100}' "${FILENAME}" > "${FILENAME}.temp"

(echo 'set terminal png size 1024,600';
 echo 'set datafile separator ","';
 echo "set output \"${OUTFILE}\"";
 echo 'set xdata time';
 echo 'set key outside';
 echo 'set timefmt "%H:%M:%S"';
 echo 'set format x "%H:%M"';
 echo 'set yrange [0:100]';
 echo 'plot "'${FILENAME}.temp'" using 1:2 title "'${TITLE}'" with lines'; \
 ) | gnuplot

#test -f "${FILENAME}.temp" && rm "${FILENAME}.temp"
unset FILENAME
unset OUTFILE
unset MAX
unset TITLE
exit 0
