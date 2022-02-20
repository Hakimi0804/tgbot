#!/bin/bash

round() {
    # e.g `round 2.3352 2`
    #            ^~~~~^
    # $1       Your number
    #
    #                   ^
    # $2    The number of decimal places
    FLOAT=$1
    DECIMAL_POINT=$2
    printf "%.${2:-$DECIMAL_POINT}f" "$FLOAT"
}

FWD_APRROVED_CHAT_ID=(
    -1001299514785 # Testing group
    -1001155763792 # My experiment chat
)
FWD_TO=-1001650345673
