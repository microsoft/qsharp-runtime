# API Dependency

(Try to keep the readability balance between the web view and raw file, give the preference to the raw file)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Directory

**public\CoreTypes.hpp**    (QUBIT, PauliId, RESULT)[, `public\QirTypes.hpp` (QirArray)].  
**public\QirContext.hpp**   Declares `GlobalContext()`.
**public\QSharpSimApi_I.hpp**
                            Defines `IQuantumGateSet`.

## Level 1

**qsharp__core__qis.hpp**   Declares `__quantum__qis__*()` gate set implementations.  
                            Depends on `public\CoreTypes.hpp` (QUBIT, PauliId, RESULT) 
                            Uses `QirArray *` from `public\QirTypes.hpp`.

**intrinsics.cpp**          Defines `__quantum__qis__*()` gate set implementation.
                            Each API depends on `GlobalContext()`, `IQuantumGateSet`.
