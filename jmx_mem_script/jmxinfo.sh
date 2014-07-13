#!/bin/bash

jps="/usr/lib/jvm/java/bin/jps"
jinfo="/usr/lib/jvm/java/bin/jinfo"

almpid=`${jps} | sort -n | head -1 | awk '{print $1}'`

echo "Java Min/Max Memory Params for ALM:"
${jinfo} ${almpid} | awk '{for (i=1;i<=NF;i++) { print $i}}' | egrep -i "xms|xmx"

xmx=`${jinfo} ${almpid} | awk '{for (i=1;i<=NF;i++) { print $i}}' | grep -i "xmx" | sed 's/-Xmx//g'`

echo "Adjustment Instructions:"
echo "========================"
echo "To set alm_min_memory = alm_max_memory"
echo "Adjust the alm_min_memory line in /home/appuser/appserver-config-latest/alm/etc/alm.cfg"
echo "To read: "
echo
echo "_X(\"ms\") { alm_min_memory || \"${xmx}\" }"