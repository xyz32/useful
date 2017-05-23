#!/bin/bash

#./getandplot.sh shroot root@10.121.240.159:/tmp/ilt/runlog_4046.csv

set -e
#set -x

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

outFileName="$(basename $2)"
inFileName="$(basename $2)"

if [ -n "$3" ]; then
    outFileName=$3
fi

sshpass -p $1 scp $2 ${inFileName}

./gnu-plot.sh ${inFileName}

mv ${inFileName}_.png ${SCRIPT_DIR}/${outFileName}.png

#while true; do sleep 300; pkill -9 -f 'java'; echo "java killed, sleep"; done