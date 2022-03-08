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

**allocationsTracker.hpp**  Defines `Microsoft::Quantum::AllocationsTracker` that tracks the allocations and detects the mem leaks.  
                            Does not depend on anything of our code.  

**utils.cpp**               Implements `__quantum__rt__fail()`, `__quantum__rt__memory_allocate()`, `__quantum__rt__heap_{alloc,free}()`.  
                            `__quantum__rt__heap_alloc()` calls **strings.cpp**'s `__quantum__rt__string_create()` - cyclical dependency.  

**strings.cpp**             Implements `QirString`, `__quantum__rt__string_*()`, `__quantum__rt__<type>_to_string()` (except `qubit_to_string` and `result_to_string`).  
                            Depends on **utils.cpp**'s `__quantum__rt__fail()` - cyclical dependency.  


## Level 2

**allocationsTracker.cpp**  Implements the internals of `Microsoft::Quantum::AllocationsTracker`.  
                            Depends on `__quantum__rt__fail()`, `__quantum__rt__string_create()`  

**context.cpp**             Implements the internals of `Microsoft::Quantum::QirExecutionContext`,  
                            Depends on **allocationsTracker.hpp**'s `Microsoft::Quantum::AllocationsTracker`.  
                            Gets/returns `IRuntimeDriver *`.

## Level 3

**delegated.cpp**           Implements `__quantum__rt__result_*()`, `__quantum__rt__qubit_{allocate,release,to_string}()`.  
                            Each API depends on `Microsoft::Quantum::GlobalContext()[->GetDriver()]`,  
                            `__quantum__rt__qubit_to_string()`  also depends on strings.cpp's `__quantum__rt__string_create()`.  
                            `__quantum__rt__result_to_string()` also depends on strings.cpp's `__quantum__rt__string_create()`.  

**arrays.cpp**              Implements {the internals of `QirArray`} and `__quantum__rt__*array*`.  
                            Depends on `Microsoft::Quantum::GlobalContext()`, `__quantum__rt__fail()`, `__quantum__rt__string_create()`,  
                            **delegated.cpp**'s `__quantum__rt__qubit_allocate()`  

## Level 4

**callables.cpp**           Defines the {internals of `QirTupleHeader`, `QirCallable`}, `__quantum__rt__tuple_*()`, `__quantum__rt__callable_*()`  
                            Depends on `QirArray`, `Microsoft::Quantum::GlobalContext()`, `__quantum__rt__fail()`, `__quantum__rt__string_create()`, `TupleWithControls`,  
                            Consider breaking up into **Tuples.cpp** and **Callables.cpp**.
