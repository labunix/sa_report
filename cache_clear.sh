#!/bin/bash
echo "[Before]"
free
sync
sync
sync
sleep 1
sysctl -w vm.drop_caches=3
echo "[After]"
free
