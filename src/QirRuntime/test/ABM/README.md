# QML benchmarks

## To build the benchmarks

1. checkout ageller/qir branch from qsharp-compiler repo
2. bootstrap and build QsCompiler.sln -> it will produce qsc.exe tool, notice its `location`
3. cd into QirRuntime/test/ABM
4. `location`\qsc.exe build --qir s --build-exe --input qsharp\circuit.qs qsharp\core.qs qsharp\target.qs --proj benchmarks (update the circuit.qs as necessary)
5. discard bridge.ll and log files, replace benchmarks.ll in ABM folder
6. from QirRuntime folder run `python build.py release`

The benchmarks were adapted from the [source](https://ms-quantum.visualstudio.com/Exploration/_git/SimulatorMeasurements) in the following way:

- Combined linear and quadratic benchmarks into single circuit.qs;
- Replaced R gates with Rz and Rx as appropriate;
- Inlined ResetAll and Reset library functions;
- Extended target.qs from ageller/qir branch to include controlled rx and controlled rz intrinsics;
- Reimplemented the C# driver in C++ (generating the array of random angles, time measurement, looping logic, etc.).

In order to successfully compile the QIR against the bridge the following changes were made to the bridge:

- added support for for controlled rx and controlled rz intrinsics.

## Running the benchmarks

abm.exe incorporates QIR-based and manually authored equivalent native circuits for linear and quadratic benchmarks.

`abm.exe 0|1 0|1 [number_qubits] [number_reps]`

1. 0 - QIR, 1 - manually authored;
2. 0 - linear, 1 - quadratic;
3. _optional_, if not provided will run the chosen configuration for 3 through 18 qubits;
4. _optional_, if not provided will run for reps, defined by 10000..1000..20000 range.

When started, amb.exe pauses to allow configuring its CPU affinity/priority.
