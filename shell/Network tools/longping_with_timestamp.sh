#!/bin/bash

TARGET="B_HOST_IP_OR_NAME"

OUTPUT_FILE="ping_result.log"

while true
do
    TIMESTAMP=$(date +"%Y-%m-%d %H:%M:%S")

    PING_RESULT=$(ping -c 1 $TARGET)

    echo "[$TIMESTAMP] $PING_RESULT" >> $OUTPUT_FILE

    sleep 1
done
