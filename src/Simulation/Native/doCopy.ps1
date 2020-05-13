param([string]$bld = "Release")

"================== COPYING $bld"
$dll = "Microsoft.Quantum.Simulator.Runtime.dll"
$srcDir = "C:\depot\Git\qsharp-runtime\src\Simulation\Native\build\$bld"
foreach ($dest in "H2O","Ham","integer-factorization") {
    foreach ($typ in "Release","Debug") {
        $dstDir = "C:\depot\Git\msr-quarc\wecker\QDK\$dest\bin\$typ"
        $dstDir += "\netcoreapp3.0\runtimes\win-x64\native"
        robocopy /NJH /NJS /NP /NDL $srcDir $dstDir $dll | Out-Null
    }
}
exit 0
