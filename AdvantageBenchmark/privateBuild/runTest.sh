#!/bin/bash

for tst in {1..3}
do
    for thrd in {20..2..-2}
    do
        for span in {7..0..-1}
        do
            export OMP_NUM_THREADS=$thrd
            export QDK_SIM_FUSESPAN=$span
            ./bin/Release/netcoreapp3.1/host $tst $tst 5
        done
    done
done
