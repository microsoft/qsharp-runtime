echo ================== COPYING %1
robocopy /NJH /NJS /NP /NDL C:\depot\Git\qsharp-runtime\src\Simulation\Native\build\%1 C:\depot\Git\msr-quarc\wecker\QDK\Ham\bin\Release\netcoreapp3.0\runtimes\win-x64\native Microsoft.Quantum.Simulator.Runtime.dll
robocopy /NJH /NJS /NP /NDL C:\depot\Git\qsharp-runtime\src\Simulation\Native\build\%1 C:\depot\Git\msr-quarc\wecker\QDK\Ham\bin\Debug\netcoreapp3.0\runtimes\win-x64\native Microsoft.Quantum.Simulator.Runtime.dll
exit 0
