# The Latest Build and Run Instructions
(The sections after this one are out-of-date)  
2022.07.15  
The [1e_0.181287518_-0.181287518.json](https://github.com/microsoft/qsharp-runtime/blob/kuzminrobin/qpeMoreTargPacks4/src/Qir/Tests/qpe/1e_0.181287518_-0.181287518.json)
(provided by Ang) is the smallest molecule that we can use to validate our decompositions and target packages.
The result of the calculation should be close to either 0.181287518 or -0.181287518, with equal probability.

The build and run instructions.
```powershell
# It is assumed 
#   that you have a clean local copy of the repo,
#   current working directory is the root of the repo.

# Enter PowerShell:
pwsh

git checkout kuzminrobin/qpeMoreTargPacks3 

# Build the full-state simulator in Debug configuration:
$Env:BUILD_CONFIGURATION = "Debug"
Push-Location "src/Simulation/Native"
.\build-native-simulator.ps1
Pop-Location

# Build the QIR Runtime in Release configuration:
$Env:BUILD_CONFIGURATION = "Release"
Push-Location "src/Qir/Runtime"
.\build-qir-runtime.ps1
# FYI: On my machine the linker `lld-link` prints a few screen pages of warnings like this
#   lld-link: warning: procedure symbol record for `__TypeMatch` in 
#   D:\a\_work\1\s\Intermediate\vctools\libvcruntime.nativeproj_520857879\objr\amd64\frame.obj 
#   refers to PDB item index 0x12B4 which is not a valid function ID record
# These warnings started after we migrated to clang-13. For now I ignore those warnings.
Pop-Location

cd src/Qir/Tests/qpe

# If the decompositions or target packages have been updated for IBMQ then 
# re-generate the "qsharp\qir\est-energy.IBMQ.ll".
Push-Location "qsharp"
dotnet build est-energy.IBMQ.csproj
    # This will update "qir/est-energy.IBMQ.ll".
    # If you need to debug it (or look at the stack trace upon crash) then 
    #   In the updated "qir/est-energy.IBMQ.ll" replace the fragments 
    #   "define internal " with fragment "define " (remove "internal " from the function definitions),
    #   and save with the name "qir/est-energy.IBMQ.no_internal.ll".
    #   In Linux/WSL this can be done with the command
    #       cat qir/est-energy.IBMQ.ll | sed -e "s/define internal /define /" > qir/est-energy.IBMQ.no_internal.ll
    #       To make sure that the substitution is correct you can use the command 
    #       diff qir/est-energy.IBMQ.ll qir/est-energy.IBMQ.no_internal.ll > qir/est-energy.IBMQ.no_internal.ll.diff
    #       and then look at the contents of the file `qir/est-energy.IBMQ.no_internal.ll.diff`. 
    #
    #   Some more info about the steps below is here - 
    #   https://stackoverflow.com/questions/31984503/is-there-a-debugger-for-llvm-ir/72398082#72398082.
    #   [Build the `https://github.com/qir-alliance/qat` tool if not yet done (I have done that in WSL), and] 
    #   According to the instructions at https://github.com/qir-alliance/qat/pull/66 
    #       generate the file "qir/est-energy.IBMQ.no_internal.dbginfo.ll" 
    #           from the qir/est-energy.IBMQ.no_internal.ll" (I do that in WSL).
    #       $QAT_REPO/build/qir/qat/Apps/qat -S qir/est-energy.IBMQ.no_internal.ll > qir/est-energy.IBMQ.no_internal.dbginfo.ll
    #   Make sure that in here 
    #   https://github.com/microsoft/qsharp-runtime/blob/316ac76180d6fa33c6810389ee4443c597e11a82/src/Qir/Tests/qpe/CMakeLists.txt#L34-L39
    #       the "qsharp/qir/est-energy.IBMQ.no_internal.dbginfo.ll" is listed 
    #       but the "qsharp/qir/est-energy.IBMQ.ll" is not, or is commented out
    #       (and other .ll files are not listed either).
    # Else (you don't need to debug it)
    #   Make sure that in here 
    #       https://github.com/microsoft/qsharp-runtime/blob/316ac76180d6fa33c6810389ee4443c597e11a82/src/Qir/Tests/qpe/CMakeLists.txt#L34-L39
    #       the "qsharp/qir/est-energy.IBMQ.ll" is listed 
    #       but the "qsharp/qir/est-energy.IBMQ.no_internal.dbginfo.ll" is not, or is commented out
    #       (and other .ll files are not listed either).
Pop-Location

# Build the QPE executable:
./build.ps1
# The `lld-link` prints a few screen pages of warnings again.

# Run the QPE executable:
./run.ps1
# For me the run now takes more than 30 minutes.
```
The sections below are out-of-date.


# Structure

The `.\py_out.json` has been generated from 
[Quantum/samples/chemistry/IntegralData/Broombridge_v0.2/LiH_sto-3g.yaml](https://github.com/microsoft/Quantum/blob/main/samples/chemistry/IntegralData/Broombridge_v0.2/LiH_sto-3g.yaml)
with the following Python script
(in Anaconda env with installed `qsharp`)
```py
# From local clone of https://github.com/microsoft/Quantum/tree/main/samples/chemistry/IntegralData/
import json
from qsharp.chemistry import load_broombridge, load_input_state, encode
data = load_broombridge('./Broombridge_v0.2/LiH_sto-3g.yaml')
problem = data.problem_description[0]
input_state = load_input_state('./Broombridge_v0.2/LiH_sto-3g.yaml', problem.initial_state_suggestions[0]['Label'])
print(json.dumps(encode(problem.load_fermion_hamiltonian(), input_state)))
```

## If you need to regenerate the QIR
See https://github.com/cgranade/qpe-for-pnnl. The `qsharp` folder from https://github.com/cgranade/qpe-for-pnnl has been copied to here and the work-around fixes were applied to `.\qsharp\Program.qs`.  
The `.\qsharp\est-energy.csproj` refers the version `0.24.39585-alpha`
(artifacts are [here](https://dev.azure.com/ms-quantum-public/Microsoft%20Quantum%20(public)/_build/results?buildId=39585&view=artifacts&pathAsName=false&type=publishedArtifacts), 
at `drop/drops/nugets`)
that has a [Q# compiler fix](https://github.com/microsoft/qsharp-compiler/pull/1373).
Or you can get the latest [Q# compiler](https://github.com/microsoft/qsharp-compiler), build it and use it.

The QIR is generated by `.\build.ps1`, the result is `.\qsharp\qir\est-energy.ll`.  

## If you don't need to or cannot regenerate the QIR
If you don't have the Q# comiler version `0.24.39585-alpha` then the generation of the `.\qsharp\qir\est-energy.ll` will fail, but a copy of it is available as `.\est-energy.ll`.
The compilation will continue.

## If you need to debug the QIR
The QAT tool, [this patch](https://github.com/qir-alliance/qat/pull/66), has been applied to `.\qsharp\qir\est-energy.ll`
in order to add the debugging information to the .ll file. The result is `.\est-energy.qat.dbginfo.ll`.

# Prerequisites
Run the `<Repo Root>\bootstrap.ps1` in the root dir of this repo. It builds the required native part of the QuantumSimulator, the QIR Runtime (and other things).
Or instead, you can set the env var `BUILD_CONFIGURATION` to `Release` and run the following scripts
* Native part of the QuantumSimulator
  * [Pre-requisites](https://github.com/microsoft/qsharp-runtime/blob/main/src/Simulation/Native/prerequisites.ps1).
  * [Build](https://github.com/microsoft/qsharp-runtime/blob/main/src/Simulation/Native/build-native-simulator.ps1).  
    If the build reports `<Repo Root>/.../Native/src/simulator/dbw_test.cpp:12:10: fatal error: 'omp.h' file not found` then feel free to ignore (it is a test) or install `libomp`.
    Just make sure that `<Repo Root>/src/Simulation/Native/build/libMicrosoft.Quantum.Simulator.Runtime.so` has been built.
* QIR Runtime
  * [Pre-requisites](https://github.com/microsoft/qsharp-runtime/blob/main/src/Qir/Runtime/prerequisites.ps1).
  * [Build](https://github.com/microsoft/qsharp-runtime/blob/main/src/Qir/Runtime/build-qir-runtime.ps1).

# Build 
`.\build.ps1`.  
The build result is in the `.\build` folder. If during the rebuild you hit unclear errors then remove the `.\build` folder and run `.\build.ps1` again.

# Run

`.\run.ps1`.  
Can take tens of minutes (or even a few hours) on a laptop to get the result.
In Linux/WSL the sanitizer may report runt-time issues in the native part of the QuantumSimulator. Feel free to ignore them for now.

# Debug

As has been mentioned above, in order to see the QIR function names in the debugger stack trace you need to apply The QAT tool, [this patch](https://github.com/qir-alliance/qat/pull/66).

## In Windows

We used the Visual Studio Code with the extension CodeLLDB (v1.7.0).  

<details><summary>The debuger configuration file "{Repo Root}/.vscode/launch.json":</summary>

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "name": "QPE", 
            "type": "lldb",
            "request": "launch",
            "cwd": "${workspaceFolder}\\src\\Qir\\Tests\\qpe", 
            "program": "${workspaceFolder}\\src\\Qir\\Tests\\qpe\\build\\qpe.exe",
            "args": ["py_out.json"],
            "environment": [
                { "name": "BUILD_CONFIGURATION", "value": "Debug" },  // Likely optional
                { "name": "PATH", "value": "../../Runtime/bin/Debug/bin;../../../Simulation/Native/build"}  // Likely optional
            ],
            "console":"integratedTerminal"
        },
    ]
}
```
</details>

## In Linux/WSL (Ubuntu 20.04)

Two options here.

### Command-line LLDB

```
lldb build/qpe py_out.json      # Launch the debugging session with LLDB debugger.
(lldb) r        # Run.
<Ctrl+c>        # Break.
(lldb) bt       # Stack Trace.
(lldb) f 1      # Select the stack trace frame 1.
(lldb) f 5      #                              5.
(lldb) q        # Quit the debugger.
```
### Visual Studio Code with the extension CodeLLDB (v1.7.0)
Make sure that you can run `./build/qpe py_out.json` in command line. For that you will likely need to adjust the `LD_LIBRARY_PATH` env var. 
```sh
export LD_LIBRARY_PATH=<absolute path to>/src/Qir/Tests/qpe/build:$LD_LIBRARY_PATH

# Make sure the var is set OK
env | grep LD_LIB

# Make sure all the lib paths are resolved correctly
ldd ./build/qpe

# Make sure the executable runs
./build/qpe py_out.json

# Kill the run
<Ctrl+c>
```
Now start the VSCode.  

<details><summary>The debuger configuration file "{Repo Root}/.vscode/launch.json:":</summary>

```json
{
    // Use IntelliSense to learn about possible attributes.
    // Hover to view descriptions of existing attributes.
    // For more information, visit: https://go.microsoft.com/fwlink/?linkid=830387
    "version": "0.2.0",
    "configurations": [
        {
            "type": "lldb",
            "request": "launch",
            "name": "QPE",
            "program": "${workspaceFolder}/src/Qir/Tests/qpe/build/qpe",
            "args": ["py_out.json"],
            "cwd": "${workspaceFolder}/src/Qir/Tests/qpe",
            //"environment": [
            //    { "name": "LD_LIBRARY_PATH", "value": "/mnt/c/ed/dev/QSharpCompiler/qsharp-runtime/qsharp-runtime_WSL/src/Qir/Tests/qpe/build" },
            //    { "name": "PATH", "value": "/mnt/c/ed/dev/QSharpCompiler/qsharp-runtime/qsharp-runtime_WSL/src/Qir/Tests/qpe/build"}
            //]
        }
    ]
}
```
</details>
