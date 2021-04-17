# API Dependency

(Try to keep the readability balance between the web view and raw file, give the preference to the raw file)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Solution

**[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}** 
                            Full state simulator common for C# Runtime and Q# Runtime. Dynamic library.

**src\Simulation\Native\src\simulator\capi.hpp**
                            Declares the APIs exposed by **[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}** .


## Level 1. External To This Directory

**public\CoreTypes.hpp**    Defines `QIR_SHARED_API`, `QUBIT`, `Qubit`, `RESULT`, `Result`, `ResultValue`, `PauliId`.  
                            Does not depend on anything of our code.

**public\QirTypes.hpp**     Defines `QirArray`, `QirString`, `PTuple`, `QirTupleHeader`, `TupleWithControls`, `QirCallable`, `QirRange`.  
                            Depends on the listed earlier ones.

**public\QirRuntime.hpp**   Declares `quantum__rt__*()`. Depends on the listed earlier ones.  

**public\QirRuntimeApi_I.hpp**  
                            Defines `IRuntimeDriver`.  
                            Depends on **public\CoreTypes.hpp**.

**public\SimFactory.hpp**   Declares `CreateToffoliSimulator()`, `CreateFullstateSimulator()`.  
                            Depends on `IRuntimeDriver`.

**public\QSharpSimApi_I.hpp**
                            Defines `IQuantumGateSet`, `IDiagnostics`.  
                            Depends on **public\CoreTypes.hpp**, `QirArray`.


## Level 2

**ToffoliSimulator.cpp**    Defines `CToffoliSimulator`, `CreateToffoliSimulator()`.  
                            Depends on `IRuntimeDriver`, `IQuantumGateSet`, `IDiagnostics`, **public\CoreTypes.hpp**

**FullstateSimulator.cpp**  Defines the `FullstateSimulator` - QIR wrapper around the **[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}**, `CreateFullstateSimulator()`.  
                            Depends on **[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}**, **src\Simulation\Native\src\simulator\capi.hpp**,
                            `IRuntimeDriver`, `IQuantumGateSet`, `IDiagnostics`.  
                            `CFullstateSimulator::GetOutStream()` depends on `quantum__rt__fail()` - the only dependency on the `public\QirRuntime.hpp`.  
                            Consider breaking up into **FullstateSimulator.hpp** and **FullstateSimulator.cpp**.
