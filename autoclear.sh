#!/bin/bash
set -e

# root check
if [ "`id -u`" -ne "0" ];then
  echo "Sorry,NotPermit User"
  exit 1
fi

# include /sbin,/usr/sbin PATH
if [ "x${PATH}" == "x" ];then
  echo "PATH Error, PATH=$PATH"
  exit 2
fi

echo "$PATH" | sed s/"\:"/"\n"/g | \
  grep '^/usr/sbin' > /dev/null 2>&1 || \
  export PATH=/usr/sbin:$PATH
echo "$PATH" | sed s/"\:"/"\n"/g | \
  grep '^/sbin'     > /dev/null 2>&1 || \
  export PATH=/sbin:$PATH

cd $(dirname $0)

case $1 in
-t|test)
  SWAPLIMIT=0
  MEMLIMIT=100
  ;;
*)
  SWAPLIMIT=1
  MEMLIMIT=70
  echo "# Usage $0 [-t|test]"
  echo "# Default:"
  echo "#   SWAPUSED>0 && MEMUSED<70; -> clear cache and reset swap."
  echo "# -t|test"
  echo "# force clear, cache and reset swap"
  echo ""
  ;;
esac

MYDATE=`env LANG=C date '+%Y/%m/%d,%H:%M:%S'`
SWAPUSED=`free | grep ^Swap | awk '{printf "%d\n",($3/$2*100)}'`
MEMUSED=`free | grep ^Mem  | awk '{printf "%d\n",($3/$2*100)}'`

function kernel_mem_clear() {
    echo "[Before]"
    echo "$MYDATE,MEMUSED=${MEMUSED}%,SWAPUSED=${SWAPUSED}%"
    free
    sync;sync;sync
    sleep 1 && sysctl -w vm.drop_caches=3
    sync;sync;sync
    sleep 1 && swapoff -a && swapon -a
    echo "[After]"
    SWAPUSED=`free | grep ^Swap | awk '{printf "%d\n",$3/$2*100}'`
    MEMUSED=`free | grep ^Mem  | awk '{printf "%d\n",$3/$2*100}'`
    echo "$MYDATE,MEMUSED=${MEMUSED}%,SWAPUSED=${SWAPUSED}%"
    free
}

if [ "$SWAPUSED" -ge "$SWAPLIMIT" ];then
  if [ "$MEMUSED" -le "$MEMLIMIT" ];then
    kernel_mem_clear
  fi
else
  echo "$MYDATE,MEMUSED=${MEMUSED}%,SWAPUSED=${SWAPUSED}%"
fi
unset SWAPUSED MEMUSED SWAPLIMIT MEMLIMIT MYDATE PATH

exit 0
