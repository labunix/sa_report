#!/bin/bash
set -e

if [ "`id -u`" -ne "0" ];then
  echo "Sorry,NotPermit User"
  exit 1
fi

if [ "x${PATH}" == "x" ];then
  echo "PATH Error, PATH=$PATH"
  exit 2
fi

echo "$PATH" | sed s/"\:"/"\n"/g | grep '^/usr/sbin' > /dev/null 2>&1 || \
  export PATH=/usr/sbin:$PATH
echo "$PATH" | sed s/"\:"/"\n"/g | grep '^/sbin'     > /dev/null 2>&1 || \
  export PATH=/sbin:$PATH

cd $(dirname $0)
# pwd
FLAG=1
TEST=""

if [ "$#" -eq 1 ];then
  case $1 in
-t|test)
  TEST=test
  ;;
*)
  echo "Do Nothing" > /dev/null
  ;;
  esac
fi

LOGFILE=autoclear.log

test -f "$LOGFILE" || touch "$LOGFILE"
test -f swapcheck.sh || \
  wget https://raw.github.com/labunix/sa_report/master/swapcheck.sh
test -f cache_clear.sh || \
  wget https://raw.github.com/labunix/sa_report/master/cache_clear.sh

test -f "$LOGFILE" || exit 1
test -f swapcheck.sh || exit 1
test -f cache_clear.sh || exit 1

chmod +x swapcheck.sh
chmod +x cache_clear.sh

exec > "$LOGFILE" 2>&1
./swapcheck.sh $TEST | grep Swap && ./cache_clear.sh && FLAG=0
if [ "$FLAG" -eq "0" ] ;then
  echo "[Swap Statistics]"
  swapon -s
  ./swapcheck.sh $TEST | grep Mem || swapoff -a && swapon -a
fi
if [ -s "$LOGFILE" ];then
  cat "$LOGFILE" | \
  mail -s "cache_clear Report" root && \
  rm "$LOGFILE"
else
  rm "$LOGFILE"
fi

unset PATH LOGFILE FLAG
exit 0
