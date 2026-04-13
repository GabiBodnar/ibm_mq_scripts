#!/bin/bash

# Usage: 
#   Run this script to extract a list of Queue Manager objects (Queues and Channels)
#   using MQSC DISPLAY commands.
#
#   This script processes one Queue Manager at a time.
#   Run this script as the 'mqm' user as follows: ./extr_obj_names.sh <QMNAME>

# --- Variable Definition ---
QM=$1

# --- 1. Error Handling ---

# CHECK FOR MISSING ARGUMENTS

if [[ -z "$QM" ]]; then
    echo "ERROR: QMNAME is missing."
    echo "Usage: $0 <QMNAME>"
    exit 1
fi

# VALIDATE QUEUE MANAGER NAME EXISTENCE

if ! dspmq -m "$QM" >/dev/null 2>&1; then
    echo "ERROR: Queue Manager '$QM' does not exist on this server."
    exit 1
fi

# --- 2. Directory Management ---

# ENSURE THE OUTPUT DIRECTORY EXISTS

if [[ ! -d "/tmp/mqm" ]]; then
    mkdir -p "/tmp/mqm"
fi

# --- 3. Object Extraction ---

echo "Extracting objects from ${QM}..."

# EXTRACT QUEUE NAMES

echo "DISPLAY Q(*)" | runmqsc "${QM}" | grep "QUEUE(" | sed 's/.*QUEUE(\([^)]*\)).*/\1/' > /tmp/mqm/"${QM}"_objects.tst

# EXTRACT CHANNEL NAMES

echo "DISPLAY CHL(*)" | runmqsc "${QM}" | grep "CHANNEL(" | sed 's/.*CHANNEL(\([^)]*\)).*/\1/' >> /tmp/mqm/"${QM}"_objects.tst

echo "Success! The object list is available at: /tmp/mqm/${QM}_objects.tst"
