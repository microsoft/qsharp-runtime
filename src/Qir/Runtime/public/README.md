# API Dependency

(Try to keep the readability balance between the web view and raw file, give the preference to the raw file)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


TODO: Consider moving `public\` one level up, or all the rest one level down the directory tree.  

## Level 0. External To This Directory

**..\..\Common\Include\qsharp__foundation_internal.hpp**
                        Depends on `QIR_SHARED_API` - consider moving below `public\`.

**..\..\Common\Include\SimulatorStub.hpp**
                        Depends on `public\` - consider moving below `public\`.


## Level 1

**TracerTypes.hpp**     Defines types `OpId`, `Time`, `Duration`, `LayerId`; constants `INVALID`, `REQUESTNEW`.  
                        Does not depend on anything of our code.  
                        Only used by Tracer and Tracer Test. Consider moving from `public` to a location still visible for tests.

**CoreTypes.hpp**       Defines `QIR_SHARED_API`, `QUBIT`, `Qubit`, `RESULT`, `Result`, `ResultValue`, `PauliId`.  
                        Does not depend on anything of our code.
                       
**QirTypes.hpp**        Defines `QirArray`, `QirString`, `PTuple`, `QirTupleHeader`, `TupleWithControls`, `QirCallable`, `QirRange`.  
                        Depends on the listed earlier ones.
                       
**QirRuntime.hpp**      Declares `quantum__rt__*()`. Depends on the listed earlier ones.  


## Level 2

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

## Level 3

**SimFactory.hpp**      Defines `CreateToffoliSimulator()`, `CreateFullstateSimulator()`.  
                        Depends on `QIR_SHARED_API`, `IRuntimeDriver`


# Qubit IDs

## Qubit IDs in plain "C" QIR API

**QUBIT** Class that is declared, but not defined. Pointer to this class never points to a class instance, instead it is just an integer - qubit id. It is needed to create a unique type in LLVM.

**Qubit** Defined as `QUBIT*`. This is never a pointer, this is always qubit ID. It is used in "C" API functions to match QIR definitions.

## Qubit IDs in "C++" classes behind plain "C" API

**qubitid_t** Defined as `uintptr_t`. This is an integer that can hold a pointer. This is used so that "C++" API is defined in terms of IDs. A reinterpret_case from `QUBIT*` to this type should be a no-op.

## Qubit IDs in the full state simulator

**unsigned** Full state simulator historically uses unsigned 32-bit integers for qubit IDs.

## Qubit IDs in Qubit Manager

**int32_t** Qubit Manager uses signed 32-bit integers for qubit IDs. Signed integers are used so that the negative range can be employed for special purposes.

## Qubit IDs in other code

Various parts of the code may also use random types for qubit IDs such as `int`. This is especially dangerous as pointers to such types are just casted to each other, even if they point to arrays.
