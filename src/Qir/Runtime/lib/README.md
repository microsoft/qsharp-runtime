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

