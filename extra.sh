#!/bin/bash

round(){
    #usage: round <number> <decimalplaces>
    #example: round 1.23452
    #returns: 1.23
    echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc));
}
