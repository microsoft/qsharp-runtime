for ($tst=1; $tst -le 2; $tst++) {
    for ($thrd=4; $thrd -ge 1; $thrd--) {
        for ($span=4; $span -ge 0; $span--) {
            $env:OMP_NUM_THREADS = $thrd
            $env:QDK_SIM_FUSESPAN = $span
            .\bin\Release\net6.0\host.exe $tst $tst 5
        }
    }
}
