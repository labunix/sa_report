#!/bin/bash

LOGDIR=/var/log/sysstat
YMDATE=`env LANG=C date --date "1 days ago" '+%Y%m'`
TARGET=`env LANG=C date --date "1 days ago" '+%d'`
YESTERDAY="${LOGDIR}/sa${TARGET}"
CPULOG="`hostname -s`_${YMDATE}${TARGET}_cpuidle.log"
MEMFREELOG="`hostname -s`_${YMDATE}${TARGET}_kbmemfree.log"
MEMUSEDLOG="`hostname -s`_${YMDATE}${TARGET}_kbmemused.log"

IDLE=8
env LANG=C sar -u -f "${YESTERDAY}" | awk '{print $'${IDLE}'}' | \
  grep idle > /dev/null 2>&1 || exit ${IDLE}

KBMEMFREE=2
env LANG=C sar -r -f "${YESTERDAY}" | awk '{print $'$KBMEMFREE'}' | \
  grep kbmemfree > /dev/null 2>&1 || exit ${KBMEMFREE}

KBMEMUSED=3
env LANG=C sar -r -f "${YESTERDAY}" | awk '{print $'$KBMEMUSED'}' | \
  grep kbmemused > /dev/null 2>&1 || exit ${KBMEMUSED}


if [ "x${IDLE}" == "x" ];then
  echo "ERROR: Not Found %idle"
  exit 1
fi
if [ "x${KBMEMFREE}" == "x" ];then
  echo "ERROR: Not Found kbmemfree"
  exit 1
fi
if [ "x${KBMEMUSED}" == "x" ];then
  echo "ERROR: Not Found kbmemused"
  exit 1
fi
  
env LANG=C sar -u -f "${YESTERDAY}" | grep "^[0-9].*all" | \
  awk '{print $1","$'${IDLE}'}' > ${CPULOG}
env LANG=C sar -r -f "${YESTERDAY}" | grep -v "[A-z]\|^\$" | \
  awk '{print $1","$'${KBMEMFREE}'}' > ${MEMFREELOG}
env LANG=C sar -r -f "${YESTERDAY}" | grep -v "[A-z]\|^\$" | \
  awk '{print $1","$'${KBMEMUSED}'}' > ${MEMUSEDLOG}
unset LOGDIR
unset YMDATE
unset TARGET
unset YESTERDAY
unset CPULOG
unset MEMFREELOG
unset MEMUSEDLOG
unset IDLE
unset KBMEMUSED
unset KBMEMFREE
exit 0
