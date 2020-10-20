# Advantage Benchmark

## Purpose

This benchmark is intended to provide an easy way to verify the performance characteristcs of a given release build of the QDK simulator vs the current tree. The releaseBuild folder contains projects that will build the quantum advantage Q# program with a QDK from a nuget source and verify the gates-per-second execution of that program. The privateBuild folder compiles the same Q# program with the runtime in the curent source tree instead.

## Executing the benchmark

To execute the benchmark, compile each version of advantage.sln using `dotnet build .\advantage.sln -c Release` from their respective folders. Then the executable to run will be either `bin\Release\netcoreapp3.1\host.exe` in the privateBuild folder or `host\bin\Release\netcoreapp3.1\host.exe` in the releaseBuild folder. This executable takes parameters describing which test circuits to execute and how many loops to perform as integer arguments, such that `host.exe 1 1 5` will run 5 loops of test 1 and `host.exe 0 3 100` will run 100 loops of tests 0 through 3. Check the contents of `privateBuild\Program.cs` to see the tests that correspond to each identifier; for most machines, test 1 aka advantage 4x4 circuit is the best choice for benchmarking.

The benchmark can also be run via runTest.ps1 or runTest.sh, which performs a sweep across configured environment variables that adjust the number of threads used and gates fused in simulating the circuit. See the definition of the script used on your platform to understand how it configures the `OMP_NUM_THREADS` and `QDK_SIM_FUSESPAN` environment variables.

## Collecting results

The output of `host.exe` is a table showing the gates-per-second along with other identifiying information for the run, output at intervals during the looped execution. When driven via runTest.ps1/.sh, the output will be a larger table of all the results for the various combinations of threads and fusion spans. To help collect these results into a meaningful table, the parseLog.py script will convert the output from a runTest execution into a CSV file with the single highest gates-per-second observed for a given thread/fuse-span combination. This can then be loaded into a spreadsheet program for easier graphing or other visualization.
