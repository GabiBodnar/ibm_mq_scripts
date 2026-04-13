#!/bin/ksh

# script makes a list of channels using cipher

# SET VARIABLE FOR OUTPUT FILE

OUTPUT="/tmp/mqm/sslciph_$(hostname).txt"

# CREATE OUTPUT FILE IF IT DOES NOT EXIST

if [[ -z "${OUTPUT}"]]; then
  mkdir -p "${OUTPUT}"
fi
> "$OUTPUT"


# CREATE QMGR VARIABLE

dspmq | awk -F '[()]' '{print $2}' | while read -r QMGR
do
  echo "${QMGR}" >> "$OUTPUT"

  # LIST CHANNEL WITH SSPCIPH PARAMETER

  DISCHL=$(echo "DISPLAY CHANNEL(*) WHERE(SSLCIPH NE '')" | runmqsc "${QMGR}")

# FORMAT THE OUTPUT OF DISPLAY CHANNEL COMMAND 

echo "$DISCHL" | awk '
  /^ *CHANNEL\(/ {
    channel_line = $0
    getline
    ssl_line = $0
    printf "%-30s %s\n", channel_line, ssl_line
  }
' >> "$OUTPUT"
echo "" >> "$OUTPUT" # PRINT IT INTO THE OUTPUT FILE

done
