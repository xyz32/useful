#!/bin/bash

#PLOT_CMD="plot "

#set -x

FULL_FILE_NAME="$(dirname ${1})/"
echo ${FULL_FILE_NAME}

for args in "$@"
do
    DATA_NAME=$(basename "${args}")
    FULL_FILE_NAME="${FULL_FILE_NAME}${DATA_NAME}_"
    DATA_NAME=$(echo "$DATA_NAME" | sed -r 's/[_]+/\\\\_/g')
    
    PLOT_CMD="set title word(columnsList, i).\" (${DATA_NAME})\" font \"sans, 15\"; ${PLOT_CMD}plot old_v = 0, \"${args}\" using (column(\"Time\")):(column(word(columnsList, i))) title (word(columnsList, i)) axis x1y1 with lines lc rgb 'red', \"\" using (column(\"Time\")):(delta_v(column(word(columnsList, i)))) title \"{/Symbol D}\".(word(columnsList, i)).\" / {/Symbol D}Time\" axis x1y2 with lines lc rgb 'green'; "
done

FILE_NAME=$(basename "${FULL_FILE_NAME}")
FILE_NAME=$(echo "$FILE_NAME" | sed -r 's/[_]+/\\\\_/g')

gnuplot << eor

# delta function
# Make sure you reset old_v=0 before you plot
old_v = 0
delta_v(x) = ( vD = x - old_v, old_v = x, vD)

columnsList="Count Pass Fail Flow Active Sleep Timeout Outgoing Incoming SockErr Kbits/s Chrono Latency TPS MSRP"
columnsListCount=words(columnsList)

#plot Data
outSize=1500*$#
set terminal pngcairo  enhanced font "arial,10" fontscale 1.0 size outSize,4000;

set output "${FULL_FILE_NAME}.png"
set datafile separator ","
set timefmt "%m/%d/%y-%H:%M:%S"

set border 10

set key autotitle columnhead left box opaque

set autoscale x
set autoscale y
set autoscale y2

#set logscale y 10
#set logscale y2 10

set grid xtics ytics y2tics mxtics mytics my2tics

set border lw 2
set ytics font "sans:bold" textcolor rgb "red"
set y2tics font "sans:bold" textcolor rgb "green"

set style data lines

set multiplot layout (columnsListCount),$# title "${FILE_NAME}"
set lmargin 10
set bmargin 3
set rmargin 10

do for [i=1:columnsListCount] {
    set xdata time
    set xlabel "Time"
    set format x "%H:%M:%S"
    set ylabel (word(columnsList, i))
    set y2label "{/Symbol D}".(word(columnsList, i))." / {/Symbol D}Time"
    set ytics nomirror
    set y2tics
    
    ${PLOT_CMD}
}
unset multiplot

eor

