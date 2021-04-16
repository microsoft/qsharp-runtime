# API Dependency

(See the raw file. Please keep the raw file readable rather than the browser-rendered one)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


To do: Consider moving `public\` one level up, or all the rest one level down the directory tree.  

## Level 0. External To This Directory
**..\..\Common\Include\qsharp__foundation_internal.hpp**
                        Depends on `QIR_SHARED_API` - consider moving below `public\`.

**..\..\Common\Include\SimulatorStub.hpp**
                        Depends on `public\` - consider moving below `public\`.


## Level
**TracerTypes.hpp**     Defines types `OpId`, `Time`, `Duration`, `LayerId`; constants `INVALID`, `REQUESTNEW`.  
                        Does not depend on anything of our code.  
                        Only used by Tracer and Tracer Test. Consider moving from `public` to a location still visible for tests.

**CoreTypes.hpp**       Defines `QIR_SHARED_API`, `QUBIT`, `Qubit`, `RESULT`, `Result`, `ResultValue`, `PauliId`.  
                        Does not depend on anything of our code.
                       
**QirTypes.hpp**        Defines `QirArray`, `QirString`, `PTuple`, `QirTupleHeader`, `TupleWithControls`, `QirCallable`, `QirRange`.  
                        Depends on the listed earlier ones.
                       
**QirRuntime.hpp**      Declares `quantum__rt__*()`. Depends on the listed earlier ones.  


## Level 

**OutputStream.hpp**    Defines `OutputStream`, `ScopedRedirector` - the means to redirect the output stream from `std::cout` to string, file, etc.  
                        Used by the tests that verify the output (e.g. `Message()`).  
                        Depends on `QIR_SHARED_API`.

**QirRuntimeApi_I.hpp** Defines `IRuntimeDriver` that provides the access to the quantum machine simulator.  
                        Depends on `QIR_SHARED_API`, `Qubit`, `Result`.

**QirContext.hpp**      Defines `QirExecutionContext`, `?Scoped`.  
                        Uses `IRuntimeDriver *`, {`AllocationsTracker *` defined in `QIR` - reverse dependency}.  
                        Depends on `QIR_SHARED_API`

**QSharpSimApi_I.hpp**  Defines `IQuantumGateSet`, `IDiagnostics`.  
                        Depends on `QIR_SHARED_API`, `Qubit`, `PauliId`, `Result`, `QirArray`.  

## Level 

**SimFactory.hpp**      Defines `CreateToffoliSimulator()`, `CreateFullstateSimulator()`.  
                        Depends on `QIR_SHARED_API`, `IRuntimeDriver`
