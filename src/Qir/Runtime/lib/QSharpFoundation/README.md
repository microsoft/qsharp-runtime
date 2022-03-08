# API Dependency

(Try to keep the readability balance between the web view and raw file, give the preference to the raw file)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Directory

**public\CoreTypes.hpp**    Defines `QIR_SHARED_API`, `QUBIT`, `Qubit`, `RESULT`, `Result`, `ResultValue`, `PauliId`.  
                            Does not depend on anything of our code.

**public\QirTypes.hpp**     Defines `QirArray`, `QirString`, `PTuple`, `QirTupleHeader`, `TupleWithControls`, `QirCallable`, `QirRange`.  
                            Depends on the listed earlier ones.

**public\QirRuntime.hpp**   Declares `__quantum__rt__*()`. Depends on the listed earlier ones.  


## Level 1

**conditionals.cpp**        Defines `__quantum__qis__apply*__body()`.  
                            Depends on QIR's `quantum__rt__result_{equal,get_zero}()`, declared in **public\QirRuntime.hpp**.  

**intrinsicsMath.cpp**      Defines `__quantum__qis__*` math funcs implementations, 
                            `Quantum::Qis::Internal::{excStrDrawRandomVal,RandomizeSeed,GetLastGeneratedRandomI64,GetLastGeneratedRandomDouble}`.  
                            Depends on `quantum__rt__fail()`, `quantum__rt__string_create()`, declared in **public\QirRuntime.hpp**.  


## Level 2

**qsharp__foundation__qis.hpp**
                            Declares `__quantum__qis__*()` math funcs and ApplyIf.  
                            Depends on **public\CoreTypes.hpp**, **public\QirTypes.hpp**.
