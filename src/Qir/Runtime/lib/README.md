# Directory Structure

[../../../Simulation/README.md](../../../Simulation/README.md)

This directory structure mirrors how the Q# language runtime itself is implemented,
namely that the QSharpFoundation is code that is specific to the concepts and patterns inherent in Q#
while QSharpCore is the default quantum instruction target package that is part of the QDK.
This was introduced as part of the target package feature work, specifically the
[PR #476](https://github.com/microsoft/qsharp-runtime/pull/476).


## QSharpFoundation
Is a project defined [here](../../../Simulation/QSharpFoundation).

## QSharpCore 
Is a project defined [here](../../../Simulation/QSharpCore).

## QIR
Anything that is required by the [QIR specs](https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR),
which in particular includes the ["methods that delegate to the simulators"](QIR/bridge-rt.ll#46), should live in the QIR folder.
They require support from the backend, but are not language-specific.  
Both the Q# Core and the Q# Foundation are Q#-specific in that these are the target instructions that the Q# libraries are built on.

Qubit allocation (`@quantum__rt__qubit_allocate()`, `@quantum__rt__qubit_release()`), as a specific example,
is not part of one target package or another, but rather part of the QSharp Foundation package,
which is why it is defined there in the QIR as well. 


# API Dependency

(Try to keep the readability balance between the web view and raw file, give the preference to the raw file)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Solution

**[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}** 
                        Full state simulator common for C# Runtime and Q# Runtime. Dynamic library.

## Level 1

**Simulators**          Defines `CToffoliSimulator`, `CreateToffoliSimulator()`, `FullstateSimulator`, `CreateFullstateSimulator()`.  
                        `FullstateSimulator` depends on the **[lib]Microsoft.Quantum.Simulator.Runtime.{dll|dylib|so}** 

## Level 2

**QIR**                 Defines the `@__quantum__rt__*` entry points (to be called by the `.ll` files generated from users' `.qs` files).  
                        Provides the access to simulators (through the `IRuntimeDriver *` returned by `GlobalContext()->GetDriver()`).

## Level 3

**QSharpFoundation**    Defines `@__quantum__qis__*()` math funcs and ApplyIf entry points.  
                        Depends on QIR (`quantum__rt__result_{equal,get_zero}()`, `quantum__rt__fail()`, `quantum__rt__string_create()`).  

**QSharpCore**          Defines `@__quantum__qis__*()` quantum gate set entry points.  
                        Each API depends on `GlobalContext()`, `IQuantumGateSet`.  
                        Uses `QirArray *` from `public\QirTypes.hpp`.
