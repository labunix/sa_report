#!/bin/bash
if [ "$#" -ne 0 ];then
  for list in "$@";do
  case $list in
-t|test)
    # Test Used / Total * 100 % threshold
    SWAPLIMIT=-1
    MEMLIMIT=0
    break
    ;;
-s:*|SWAPLIMIT=*)
    SWAPLIMIT=`echo $1 | sed s/"="/":"/ | awk -F\: '{print $2}'`
    shift;
    ;;
-m:*|MEMLIMIT=*)
    MEMLIMIT=`echo $1  | sed s/"="/":"/ | awk -F\: '{print $2}'`
    shift;
    ;;
-h|--help|*)
    echo "# at 1st Test"
    echo "Usage $0 [OPTION]"
    echo ""
    echo "-h,--help			This Help"
    echo "-t,test			Test Mode"
    echo "				SWAPLIMIT=-1,MEMLIMIT=0"
    echo "-s:[num],SWAPLIMIT=[num]	num is -1 to 99"
    echo "-m:[num],MEMLIMIT=[num]	num is -1 to 99"
    echo ""
    echo "DEFAULT			SWAPLIMIT=0,MEMLIMIT=70"
    exit 1;
    ;;
    esac
  done
fi

if [ "x$MEMLIMIT" == "x" ];then
  MEMLIMIT=70
fi
if [ "x$SWAPLIMIT" == "x" ];then
  SWAPLIMIT=0
fi

# Swap Over 0%,Memory Over 70%
free | grep ^Swap | \
  awk '{if (($3/$2*100)>'"${SWAPLIMIT}"') print "Swap Used " ($3/$2*100)"%"}'
free | grep ^Mem  | \
  awk '{if (($3/$2*100)>'"${MEMLIMIT}"') print "Limit Check "($3/$2*100)}'

unset SWAPLIMIT MEMLIMIT list
exit 0


