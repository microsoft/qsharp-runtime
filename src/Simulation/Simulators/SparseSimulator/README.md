# Introduction
This is a an alternative quantum simulator, compatible with Q\# and Microsoft's quantum development kit. It is efficient for algorithms with a smaller number of states in superposition, regardless of the number of qubits.

# Repository Structure

/SparseQuantumSimulator/  
|--/Native/: C++ code for the simulator  
|--/SparseSimulatorCS/: C# library for the simulator  
|--/SparseSimQSharpTests/: Several Q# tests of the simulator  
|--/SparseSimulatorTests/: C++ tests of the simulator  

# Dependencies
 - CMake v1.2.0
 - Q\# v0.15.2101126940
 - C++11
 - Dotnet core v 3.1
 - Dotnet cake v1.1.0

# Setup
To build the Sparse Simulator, call `dotnet restore` from the main `SparseSimulator` folder, then `dotnet cake`. This builds the C++ backend and the C\# interface. 

To use the SparseSimulator in a Q\# project, ensure that it includes
`<ItemGroup>`
`    <ProjectReference Include="path/to/SparseSimulator/SparseSimulatorCS/SparseSimulator.csproj"/>`
`</ItemGroup>`
in the `.csproj` file, to import the sparse simulator. 

The C\# sparse simulator class and all its Q\# functions are in the `Microsoft.Quantum.SparseSimulation` namespace. 

A sparse simulator object can be initialized in C\# by calling `SparseSimulator()`. In an executable Q\# project, add 
`<DefaultSimulator>Microsoft.Quantum.SparseSimulation.SparseSimulator</DefaultSimulator>`
to the property group in the `.csproj` file.

To run a test with the sparse simulator, add `@Test("Microsoft.Quantum.SparseSimulation.SparseSimulator")` above the test operation.

# Other

## Qubit Capacity
The simulator has a qubit capacity which can be either 64, 128, 256, 512, or 1024. The capacity is only related to the internal data structure of quantum states, and only needs to be at least as large as the number of qubits actually in use. By default it starts with 64 qubits, and allocating more than 64 qubits will simply increase its capacity to accommodate this. It can be initialized with more qubits with an optional argument to C\#, i.e., `var sim = SparseSimulator(128)` will initialize with capacity for 128 qubits.

## Emulation
Currently the simulator only emulates AND and adjoint AND gates. It asserts that the target qubit is |0> before the AND and after the adjoint AND.

## Statistics
By default, the simulator tracks the total number of qubits used. It also tracks the number of occupied qubits, which is based on whether they are ever in a non-zero state. That is, if one allocates a qubit and applies Z to it, the simulator will still regard it as unoccupied because it wil still be in the |0> state.

## Assertion optimizations
Z-assertions can be treated as phase/permutation gates, and thus in a Release build, they are added to the queue and not immediately run. This means if such an assertion fails, it might not give an error until much later in the execution. In a Debug build, they are executed immediately (which will slow down execution, but be more helpful for debugging).


# Special Operations
The sparse simulator has some extra C\# Q\# operations for specific purposes.

## Member functions of `SparseSimulator`
`SetLogging(bool)`: Logging is set to `false` by default; if set to true, the simulator will output the name of each operation as it executes them. 

## Q\# Functions

`GetAmplitudeFromInt(qubit : Qubit[], label : Int)`: Uses `label` as a bitstring to index the qubits in `qubit`. It returns the amplitude of the state with that label, where the value of all other qubits is 0.

`GetAmplitude(qubit : Qubit[], label : BigInt) : Complex` : Same as `GetAmplitudeFromInt`, but uses a BigInt as an index.

`AssertProbBigInt (stateIndex : BigInt, expected : Double, qubits : Microsoft.Quantum.Arithmetic.LittleEndian, tolerance : Double) : Unit`: Asserts that the probability to measure the qubits in `Qubits` and find the value `stateIndex` is within `tolerance` of the expected probability `expected`.

`Sample(register : qubit [])`: This acts like measuring `register` in the Pauli-Z basis, and returns a boolean array of the result of that measurement, except it is non-destructive. 

# Adding Gates

To add a gate to the simulator, you will need to add it to:
- SparseSimulatorCS/SparseSimulator.cs
- Native/capi.cpp
- Native/quantum_state.hpp
- Native/basic_quantum_state.hpp
- Native/SparseSimulator.h

Optionally, you may need to add a Q\# and C\# file to the SparseSimulatorCS folder, to create a Q\# operation to call the gate if it does not already exist.

## Quantum State (quantum_state.hpp and basec_quantum_state.hpp)
This code will modify the actual wavefunction data structure. The code for the `H` gate will be a good template. Typically, such a function will create a new wavefunction object, then iterate through the existing wavefunction to compute new (label, amplitude) pairs, which are inserted into the new wavefunction. Finally, it moves the new data into the old wavefunction object. 

Since the hash map does not allow modifications while iterating through it, this is the only way to implement most gates.

Finally, the `BasicQuantumState` class needs to implement the same function virtually, so the `SparseSimulator` class can call it.

## SparseSimulator (SparseSimulator.h)
The `SparseSimulator` class will also need a wrapper function for the new gate. This will call `_quantum_state->your_new_gate(args...);`. However, `SparseSimulator` also manages gate queues, so you will need to decide how the new gate commutes with existing ones. The simplest approach will be to start by calling `_execute_queued_ops();`, which will flush all the gate queues and allow you to run your gate without needing any commutation relations.

## C API (capi.cpp)
Within capi.cpp, you need to add a new wrapper to call the function in `SparseSimulator`. The first argument must be an unsigned integer, representing the ID of the simulator, so you will call it as 
`getSimulator(sim_id)->your_new_gate(\# args \#);`
For more complicated arguments from C\#, the other functions provide a template. For consistency, append "\_cpp" to the end of the function name in capi.cpp.


## SparseSimulator (SparseSimulator.cs)
Here the C\# code will call your new gate. The wrapper must go in the `SparseSimulatorProcessor` class, and must have the following form:
`private static extern void your_new_gate_cpp(uint sim, \# args\#);`
`public override void Your_new_gate(\#args\#)
{
    your_new_gate_cpp(Id, \# arguments, parsed into a format that C++ can read\#);
}`
Here `Id` is an internal variable for the simulator's ID, which must be passed to C++.

## (Optional) Q\# Code
If you are implementing a gate that Q\# already expects (i.e., it is initialized in the `QuantumProcessorBase` class) then the previous steps will be enough. However, if you want to create an entirely new gate, you will need to create a Q\# operation to call it.

"Probes.qs" and "Probes.cs" provide a template for how this code will look. In Q\#, declare the operation `YourNewGate` with code `body intrinsic;`. Then in a separate C\# file, use the following template:
`public partial class YourNewGate
{
    public class Native : YourNewGate
    {
        private SparseSimulator sim = null;
        public Native(IOperationFactory m) : base(m)
        {
            sim = m as SparseSimulator;
        }
        public override Func<\#input types from Q\#\#, \#output types to Q\#\#> __Body__ => sim == null ? base.__Body__ : (args) => {
            return sim.Your_new_gate(args.Item1, args.Item2,...);
        };
    }
}`

You will also need to add
`public partial class SparseSimulator : QuantumProcessorDispatcher, IDisposable
{
    public \# Q\# return type\# Your_new_gate(\#args\#)
    {
        return ((SparseSimulatorProcessor)this.QuantumProcessor).Your_new_gate(\#args\#);
    }
}
`
which tells the `SparseSimulator` class to forward the call to its internal `SparseSimulatorProcessor` class.


# Internal Logic
We desribe the main data structure strategies and optimizations in the paper at https://arxiv.org/abs/2105.01533.

## Threading Logic
The multithreading uses OpenMP where possible, but the Visual Studio compiler's version is too low, and hence it relies on std::thread. The build detects the version of OpenMP:
 - If OpenMP is not available, it does not set the flags `DOMP_GE_V3` nor `_OPENMP`. This will select std::thread and use `std::hardware_concurrency` to decide on the number of threads.
 - If OpenMP is available but the version is too low (i.e., Visual Studio), it does not set `DOMP_GE_V3` but does set `_OPENMP`. Here it will use std::thread but use `omp_get_num_threads` to decide on the number of threads.
 - If OpenMP is availalble and the version is at least 3, it will set both flags to 1 and use OpenMP parallelism


# Future Optimizations

## Delayed Release
Currently the simulator executes any queued operations on any qubits it needs to release. This is not strictly necessary: it could add an assertion that the qubits are zero, and continue on. However, it's important to set the `_occupied_qubits` vector to be `0` for that qubit after it is released, but this will not necessarily be true if the gates are not executed. Hence, to delay the release of qubits, it will need a more involved method to track occupied qubits, and qubits which are actually 0.


# Licence
The wavefunction uses the bytell hash map written by Malte Skarupke, which has the following licence:

Copyright Malte Skarupke 2017.
Distributed under the Boost Software License, Version 1.0.
    (See http://www.boost.org/LICENSE_1_0.txt)