for ($tst=1; $tst -le 3; $tst++) {
    for ($thrd=6; $thrd -ge 1; $thrd--) {
        for ($span=7; $span -ge 0; $span--) {
            $env:OMP_NUM_THREADS = $thrd
            $env:QDK_SIM_FUSESPAN = $span
            .\bin\Release\netcoreapp3.1\host.exe $tst $tst 5
        }
    }
}
