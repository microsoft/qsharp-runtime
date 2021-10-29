
These are my notes of the steps I followed to be able to compile the DatabaseSearch project in the [Q# samples repository](https://github.com/microsoft/Quantum) into QIR, and then use the QIR runtime to simulate and trace it.

# pre-reqs

Checked out the repos [qsharp-runtime](https://github.com/microsoft/qsharp-runtime) and [Quantum (i.e. samples)](https://github.com/microsoft/Quantum) under a `~/Repos` folder

Installed: 

  * powershell 7+ (brew install --cask powershell): needed to run all build scripts
  * cmake 3.20+ (brew install cmake): all our native projects are based on cmake for x-platform support
  * clang (xcode-select --install): needed to compile native code
  * dotnet: needed by the Q# compiler and qir-cli tool.

  > Note: there might be other dependencies that were already installed on my environment. Also, `bootstrap.ps1` installs Rust automatically (used for the experimental simulator), and might install other things.


# Build Runtime components

Run bootstrap.ps1 under root to build Native simulators and basic Qir runtime
```
cd ~/Repos/qsharp-rutnime
pwhs ./bootstrap.ps1
```

Build rest of Qir:
```
cd ~/Repos/qsharp-runtime/src/Qir
pwsh ./build_all.ps1
```

Finally, pack and install the `qir-cli`:
```
cd ~/Repos/qsharp-runtime/src/Qir/CommandLineTool
dotnet pack
dotnet tool install -g Microsoft.Quantum.Qir.CommandLineTool --add-source ./bin/Debug/
```

# Using the QIR runtime to simulate a Q# program

## 1. Generate QIR from Q# project

Generate the QIR representation of a Q# program simply by passing the `QirGeneration` flag at build time:
```
cd ~/Repos/Quantum/samples/algorithms/database-search 
dotnet build /property:QirGeneration=true
```

## 2. Create an executable to simulate the QIR program using the `qir-cli` tool

The *easiest* way to compile a QIR program for local simulation is to use the `qir-cli` tool.

The `qir-cli` takes as input a dll of a Q# program (that must be generated with the `QirGeneration` flag on) and a target folder. The tool compiles the Q# program into one or more executables, one for each @EntryPoint.
```
qir-cli --dll bin/Debug/netcoreapp3.1/DatabaseSearchSample.dll --exe qir
```

Notice the output:
```
$ ls qir
-rw-r--r-- 1 anpaz staff  730693 Oct 19 11:47 DatabaseSearchSample.ll
-rwxr-xr-x 1 anpaz staff 1731176 Oct 19 11:48 Microsoft__Quantum__Samples__DatabaseSearch__RunMultipleQuantumSearch__Interop.exe
-rwxr-xr-x 1 anpaz staff 1731176 Oct 19 11:48 Microsoft__Quantum__Samples__DatabaseSearch__RunQuantumSearch__Interop.exe
-rwxr-xr-x 1 anpaz staff 1731176 Oct 19 11:48 Microsoft__Quantum__Samples__DatabaseSearch__RunRandomSearch__Interop.exe
-rwxr--r-- 1 anpaz staff 1151120 Oct 19 11:33 libMicrosoft.Quantum.Qir.QSharp.Core.dylib
-rwxr--r-- 1 anpaz staff  217048 Oct 19 11:33 libMicrosoft.Quantum.Qir.QSharp.Foundation.dylib
-rwxr--r-- 1 anpaz staff 1923040 Oct 19 11:33 libMicrosoft.Quantum.Qir.Runtime.dylib
```

It created three executables, one for each @EntryPoint (`RunRandomSearch`, `RunQuantumSearch` and `RunMultipleQuantumSearch`). 
The name reflects the fully qualified name of the EntryPoint, plus `__Interop.exe`. 
Since the Q# QIR itself doesn't have a `main` method, the `qir-cli` automatically creates one
that creates an instance of the FullStateSimulator to simulate the corresponding EntryPoint parsing and passing down any arguments.

It also adds the QIR runtime dlls that are needed for execution, but it's *critically missing* the FullState simulator dll which needs to be manually copied:
```
cd qir
cp ~/Repos/qsharp-runtime/src/Simulation/Native/build/libMicrosoft.Quantum.Simulator.Runtime.dylib .
```

To run the program, it needs to find the QIR and Simulator dynamic libraries, so first set the `LD_LIBRARY_PATH` to include the current folder, then run the program:
```
export LD_LIBRARY_PATH=.
./Microsoft__Quantum__Samples__DatabaseSearch__RunQuantumSearch__Interop.exe
```

It gives an output similar to this:
```
Quantum search for marked element in database.
  Database size: 64.
  Classical success probability: 0.015625
  Queries per search: 7 
  Quantum success probability: 0.59138015005737521

Attempt 10. Success: Zero,  Probability: 0.5 Speedup: 4.57099999999999973 Found database index [Zero, One, One, Zero, One, Zero]
Attempt 20. Success: Zero,  Probability: 0.59999999999999998 Speedup: 5.48599999999999977 Found database index [One, Zero, Zero, Zero, Zero, Zero]
Attempt 30. Success: One,  Probability: 0.5 Speedup: 4.57099999999999973 Found database index [One, One, One, One, One, One]
Attempt 40. Success: Zero,  Probability: 0.55000000000000004 Speedup: 5.02899999999999991 Found database index [One, One, Zero, Zero, Zero, One]
Attempt 50. Success: One,  Probability: 0.56000000000000005 Speedup: 5.12000000000000011 Found database index [One, One, One, One, One, One]
Attempt 60. Success: One,  Probability: 0.56699999999999995 Speedup: 5.18400000000000016 Found database index [One, One, One, One, One, One]
Attempt 70. Success: Zero,  Probability: 0.51400000000000001 Speedup: 4.69899999999999984 Found database index [Zero, Zero, Zero, Zero, Zero, One]
Attempt 80. Success: One,  Probability: 0.55000000000000004 Speedup: 5.02899999999999991 Found database index [One, One, One, One, One, One]
Attempt 90. Success: Zero,  Probability: 0.54400000000000004 Speedup: 4.9740000000000002 Found database index [Zero, One, One, One, Zero, One]
Attempt 100. Success: Zero,  Probability: 0.56000000000000005 Speedup: 5.12000000000000011 Found database index [One, One, Zero, One, Zero, Zero]
```

# Using the QIR runtime to Trace a Q# program

QIR's Tracer is not incoroporated into the Q# or the `qir-tool`, as such all the steps need
to be manually followed.

## 1. Generate QIR from Q# project

We can't use the OOTB QIR generation for the Tracer library.  Tracer requires its own set of intrinsic operations and all regular intrinsic operations need to be decomposed accordingly. At a high level, all  operations we wish to track need to decompose to a call to either `single_qubit_op` 
or `multi_qubit_op`.

A Q# file with such decompositions can be found at `qsharp-runtime/src/Qir/Tests/QIR-tracer/qsharp/tracer-target.qs`.
To incorporate this into your project, download and copy it to your projects src folder, e.g.:
```
cd ~/Repos/Quantum/samples/algorithms/database-search
cp ~/Repos/qsharp-runtime/src/Qir/Tests/QIR-tracer/qsharp/tracer-target.qs .
```

However, trying to compile this with `dotnet build /property:QirGeneration=true` triggers errors as the Intrinsics are duplicated.

To fix this we need to remove the built-in intrinsics library when calling the Q# compiler.
There are a couple of ways to do this, what I did is I modified the resource file generated for the
`QirGeneration=true` the parameter (i.e. `obj/qsharp/config/qsc.rsp`) and remove the `Microsoft.Quantum.QSharp.Core.dll` from it, then call directly the Q# comipler:
```
dotnet ~/.nuget/packages/microsoft.quantum.sdk/0.19.2109165653/DefaultItems/../tools/qsc/qsc.dll  build --format MsBuild -v Normal --response-files  obj/qsharp/config/qsc.rsp 
```

> Note the `tracer-target.qs` is missing a couple of intrinsics:
>   * `R1`
>   * `Reset`
>   * `ResetAll`
>   * `MResetZ`
> which I manually added to compile successfully.

This generates two versions of the QIR code:

1. `qir/DatabaseSearchSample.ll`: with the text version
2. `obj/qsharp/DatabaseSearchSample.bc`: with the binary version




## Compile qir

It's very simple:
```
c++ -c qir/DatabaseSearchSample.ll -o output/qir.o
```

## Generate & compile driver

The generated QIR code does not have a built-in `main` function. A driver
program that initializes the Tracer and invokes the operation is needed. The
driver also needs a mapping from operation ids to names.

I chose to modify the driver auto-generated by the `qir-tool`. The new file can be found in this gist:
[tracer-driver.cpp](https://gist.github.com/anpaz/893fec94a6d58b0bfc8c12267c7f0a7a)

Download the file into the `database-search` folder and compile it:
```
wget https://gist.githubusercontent.com/anpaz/893fec94a6d58b0bfc8c12267c7f0a7a/raw/e00872d0d7904b8174f17c807e1d1efccb73098c/tracer-driver.cpp -O tracer-driver.cpp 
c++ -c tracer-driver.cpp -o output/tracer-driver.o  -std=gnu++17 -I ~/Repos/qsharp-runtime/src/Qir/Runtime/public
```

Another required step is to make the runtime QIR libraries discoverable for the linker and at runtime.
To achieve this, create a `lib` folder, and copy all the dlls from the Qir bin output folder. Then
set
```
mkdir lib
find ~/Repos/qsharp-runtime/src/Qir/Runtime/bin/Debug/bin -name "*.dylib" -exec cp "{}" lib \;
export LIBRARY_PATH=$LIBRARY_PATH:lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:lib
```

Now we can link everything to generate an executble `a.out`:
```
c++ output/qir.o output/tracer-driver.o  \
    -lMicrosoft.Quantum.Qir.Runtime  \
    -lMicrosoft.Quantum.Qir.QSharp.Foundation  \
    -lMicrosoft.Quantum.Qir.QSharp.Core \
    -lMicrosoft.Quantum.Qir.Tracer
```

To trace the Q# operation, run the program, the output should be something like this:
```
Quantum search for marked element in database.
  Database size: 64.
  Classical success probability: 0.015625
  Queries per search: 7 
  Quantum success probability: 0.59138015005737521

Attempt 10. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 20. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 30. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 40. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 50. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 60. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 70. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 80. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 90. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
Attempt 100. Success: Zero,  Probability: 1.0 Speedup: 9.14300000000000068 Found database index [Zero, Zero, Zero, Zero, Zero, Zero]
layer_id,name,X,MCX,MCZ,H,Rx,100
0,,0,0,0,600,0,0
1,,0,100,0,0,0,0
2,,0,0,0,0,100,0
3,,0,100,0,0,0,0
4,,100,0,0,600,0,0
5,,600,0,0,0,0,0
6,,0,0,100,0,0,0
7,,700,0,0,0,0,0
8,,0,0,0,600,0,0
9,,0,100,0,0,0,0
10,,0,0,0,0,100,0
11,,0,100,0,0,0,0
12,,100,0,0,600,0,0
13,,600,0,0,0,0,0
14,,0,0,100,0,0,0
15,,700,0,0,0,0,0
16,,0,0,0,600,0,0
17,,0,100,0,0,0,0
18,,0,0,0,0,100,0
19,,0,100,0,0,0,0
20,,100,0,0,600,0,0
21,,600,0,0,0,0,0
22,,0,0,100,0,0,0
23,,700,0,0,0,0,0
24,,0,0,0,600,0,0
25,,0,100,0,0,0,0
26,,0,0,0,0,0,700
```

> Note: The Q# operation calls Measure for the output, which currently triggers an Exception on Tracer.
> I modified the code and recompile to simply return Zero.