for ($span=0; $span -le 7; $span++) {
    for ($thrd=1; $thrd -le 16; $thrd++) {
        $env:OMP_NUM_THREADS = $thrd
        $env:QDK_SIM_FUSESPAN = $span
        .\bin\Release\netcoreapp3.1\host.exe
    }
}
