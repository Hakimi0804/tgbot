#!/bin/bash

round() {
    # $1 = Your number
    # $2 = Amount of decimal places
    FLOAT=$1
    DECIMAL_POINT=$2
    printf "%.${2:-$DECIMAL_POINT}f" "$FLOAT"
}

FWD_APRROVED_CHAT_ID=(
    -1001299514785 # Testing group
    -1001155763792 # My experiment chat
)
FWD_TO=-1001650345673
SAVING_GROUP_ID=-1001607510711
BOT_OWNER_ID=1024853832
