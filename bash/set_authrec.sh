#!/bin/bash

# Purpose: Filters 'SET AUTHREC' commands from an Origin Queue Manager to match 
#          objects that actually exist on a Destination Queue Manager.
#          (Supports: QUEUES, CHANNELS, and QMGR objects).
#
# Usage: 
#   1. On the Destination QM server, run the extraction script:
#      ./extr_obj_names.sh <DEST_QM>
#     
#   2. Copy the resulting .tst file to the Origin server.
#
#   3. Run this script on the Origin server:
#      ./set_authrec.sh <ORIG_QM> <USER_ID|ALL> /path/to/DEST_QM_objects.tst

# ------ 1. Validation -------

# COUNT NUMBER OF ARGUMENTS

if [ "$#" -ne 3 ]; then
    echo "ERROR: Please provide exactly 3 arguments."
    echo "Example: $0 <ORIG_QM> <USER> </directory/"${DEST_QM}"_objects.tst>"
    exit 1
fi

# ASSIGN ARGUMENTS TO VARIABLES

ORIG_QM=$1
USER=$2
GUEST_LIST=$3 # This is the file copied from Destination QM

INPUT="/tmp/mqm/set_authrec_input.tst" 
OUTPUT="/tmp/mqm/set_authrec_output.mqsc" # output file for DESTINATION QM

# ENSURE FILE EXISTS

if [[ ! -f "$GUEST_LIST" ]]; then
    echo "ERROR: File '$GUEST_LIST' not found on disk!"
    exit 1
fi

# ENSURE DIRECTORY EXISTS

if [[ ! -d "/tmp/mqm" ]]; then
mkdir -p "/tmp/mqm"
fi

# ------- 2. Pull SET AUTHREC from ORIGIN QM --------

echo "Extracting authorizations from ${ORIG_QM}..."
echo
if [ "$USER" == "ALL" ]; then 
    dmpmqcfg -m "${ORIG_QM}" -o 1line | grep "SET AUTHREC" > "${INPUT}" # get all authorizations
else    
    dmpmqcfg -m "${ORIG_QM}" -o 1line | grep "SET AUTHREC" | grep -w "${USER}" > "${INPUT}" #list of all $USER`s authorizations from ORIGIN QM
fi 

# ------- 3. Filtering Loop ---------

# CLEAR THE OUTPUT FILE

> "${OUTPUT}"

echo "Filtering necessary authorizations.."
echo

while read -r line; do
    # SKIP: Line that does not start with the word "SET"
    if [[ ! "$line" == SET* ]]; then
        continue
    fi

 #  Extract clean profile name ( remove quotes, brackets, and hidden spaces)
    profile_name=$(echo "$line" | sed "s/.*PROFILE('\?\([^')]*\)'\?).*/\1/" | tr -d "' " | tr -d '\r')

 # RULE A: Generic profiles (with *) always go to output
    if [[ "$profile_name" == *"*"* ]]; then
        echo "$line" >> "$OUTPUT"
        continue
    fi
#  RULE B: (ORIGIN QMGR name to 'SELF')
    if [[ "$line" == *"OBJTYPE(QMGR)"* ]]; then
        echo "$line" | sed "s/PROFILE([^)]*)/PROFILE(SELF)/" >> "$OUTPUT"
        continue
    fi

#  RULE C: Specific objects must exist in the GUEST_LIST (Exact match)
# -q (quiet), -F (fixed string), -x (exact line match)
    if grep -qxF "$profile_name" "$GUEST_LIST"; then
        echo "$line" >> "$OUTPUT"
    fi

done < "${INPUT}"

echo "------------------------------------------------"
echo
echo "Done! Check ${OUTPUT} file"
echo
echo "You can now run: runmqsc DEST_QM < ${OUTPUT}"
