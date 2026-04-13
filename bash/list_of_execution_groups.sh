#!/bin/bash

# script makes a list of running execution groups on broker queue manager
# run as broker user

# BROKER QM VARIABLE

BROKER=$1

# EXTRACT NAMES OF RUNNING EXECUTION GROUPS , SAVE THEM TO A TEXT FILE

mqsilist "${BROKER}" | grep "${BROKER}" | grep -v "PRG0.*" |  awk -F "'" '{print $2}' >> /tmp/mqm/list_of_eg_"${BROKER}".txt 

