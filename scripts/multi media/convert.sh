#!/bin/bash

set -x

pushd "${1}"

for fullFileName in ./*.MOV; do
  filename=$(basename "$fullFileName")
  extension="${filename##*.}"
  filename="${filename%.*}"
  if [ ! -f ./${filename}.avi ]
  then
    mencoder "./${fullFileName}" -o "./${filename}.avi" -oac mp3lame -ovc x264
  fi
done

popd
