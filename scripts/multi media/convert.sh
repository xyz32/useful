#!/bin/bash

set -x

function convert() {
    pushd "${1}"
    
    FILES=$(find . -type f -iname '*.MOV' |sort|uniq)

    IFS="\n"
    for fullFileName in ${FILES}
    do
        filename=$(basename "${fullFileName}")
        extension="${filename##*.}"
        filename="${filename%.*}"
        mencoder "${fullFileName}" -o "${filename}.avi" -oac mp3lame -ovc x264
        mv "${fullFileName}" "${fullFileName}.done"
    done

    popd
}

OIFS=$IFS

FOLDERS=$(find "${1}" -type f -iname '*.MOV' -printf '%h\n'|sort|uniq)
IFS="\n"
for folder in ${FOLDERS}
do
    echo "===============================================> Converting: ${folder}"
    convert "${folder}"
done

IFS=$OIFS

