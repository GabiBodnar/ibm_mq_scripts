#!/bin/bash

# script to change cluster parameter to 'DUMMY'
# run as 'mqm' user
# run script by typing command : $ ./remove_queues_from_cluster.sh $QMGR $CLUSNAME

# QUEUE MANAGER VARIABLE

QMGR=$1
CLUSNAME=$2

# TEST IF VARIABLE IS DEFINED; DISPLAY ERROR IF NOT

if [ -z "$QMGR" ]; then
    echo "Error: Queue manager is not defined."
    exit 1
elif [ -z "$CLUSNAME" ]; then
    echo "Error: Cluster name is missing."
    exit 1
fi

# IF OUTPUT DIRECTORY DOES NOT EXIST, CREATE IT

if [ ! -d /tmp/mqm ]; then
    mkdir -p /tmp/mqm
fi

# LIST LOCAL QUEUES WITH REQUIRED CLUSTER PARAMETER

echo "DIS QL (*) WHERE (CLUSTER EQ '"${CLUSNAME}"')" | runmqsc "${QMGR}" | grep "QUEUE(" | sed 's/.*QUEUE(\([^)]*\)).*/\1/'  > /tmp/mqm/queue_list.txt

# CHECK IF OUTPUT FILE HAS CONTENT

if [[ ! -s "/tmp/mqm/queue_list.txt" ]]; then
    echo "Output file is empty"
    exit 0
fi

# LOOP OVER QUEUE LIST

while read ql; do
# change cluster to 'DUMMY'
echo "ALTER QL(${ql}) CLUSTER('DUMMY')" | runmqsc "${QMGR}" >> /tmp/mqm/cluster_change_output.txt
done < /tmp/mqm/queue_list.txt

# REMOVE FILES

rm /tmp/mqm/cluster_change_output.txt
rm /tmp/mqm/queue_list.txt
