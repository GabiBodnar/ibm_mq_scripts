#!/bin/ksh
# script displays all the channels that are in either "stopped" or "retrying" status
 
# QMGR VARIABLE

dspmq | awk -F '[()]' '{print $2}' | while read QMGR

do

# SHOW THE NAME OF QMGR AT THE TOP OF THE CLAUSE

echo CHANNELS OF QM: "${QMGR}"
echo ""

# DISPLAY CHANNELS

echo "DIS CHS (*) WHERE (STATUS NE RUNNING)" | runmqsc "${QMGR}" | awk '{print $1}' | grep CHANNEL

echo ""
echo ""

done

