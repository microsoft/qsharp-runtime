# API Dependency

(See the raw file. Please keep the raw file readable rather than the browser-rendered one)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Directory
**public\CoreTypes.hpp**    (QUBIT, PauliId, RESULT)[, `public\QirTypes.hpp` (QirArray)].  
**public\QirContext.hpp**   Declares `GlobalContext()`.
**public\QSharpSimApi_I.hpp**
                            Defines `IQuantumGateSet`.

## Level 
**qsharp__core__qis.hpp**   Declares `quantum__qis__*()` gate set implementations.  
                            Depends on `public\CoreTypes.hpp` (QUBIT, PauliId, RESULT) 
                            Uses `QirArray *` from `public\QirTypes.hpp`.

**intrinsics.cpp**          Defines `quantum__qis__*()` gate set implementation.
                            Each API depends on `GlobalContext()`, `IQuantumGateSet`.

## Level 
**qsharp-core-qis.ll**      Defines `@__quantum__qis__*()` quantum gate set entry points (to be called by the `.ll` files generated from users' `.qs` files).  
                            The C++ Standard reserves the identifiers starting with double underscores `__`, that is why the definitions of `@__quantum__qis__*`
                            have been put to `.ll` file rather than `.cpp` file.  
                            Depends on `quantum__qis__*` implementations (in **intrinsics.cpp**).  
