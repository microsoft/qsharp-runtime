for span in {0..7}
    for thrd in {1..16}
    do
        export OMP_NUM_THREADS=$thrd
        export QDK_SIM_FUSESPAN=$span
        ./bin/Release/netcoreapp3.1/host.exe
    done
do
done
