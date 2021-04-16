# API Dependency

(See the raw file. Please keep the raw file readable rather than the browser-rendered one)

The listed earlier ones provide the functionality to the listed later ones  
(the listed later ones include and/or call the listed earlier ones,  
the listed later ones cannot be compiled into an executable without the listed earlier ones).  

Same-level entities are independent of each other (unless specified otherwise). Entities depend on the levels listed earlier only.  


## Level 0. External To This Directory

**public\CoreTypes.hpp**    Defines `QIR_SHARED_API`, `QUBIT`, `Qubit`, `RESULT`, `Result`, `ResultValue`, `PauliId`.  
                            Does not depend on anything of our code.

**public\QirTypes.hpp**     Defines `QirArray`, `QirString`, `PTuple`, `QirTupleHeader`, `TupleWithControls`, `QirCallable`, `QirRange`.  
                            Depends on the listed earlier ones.

**public\QirRuntime.hpp**   Declares `quantum__rt__*()`. Depends on the listed earlier ones.  


## Level 1
**allocationsTracker.hpp**  Defines `Microsoft::Quantum::AllocationsTracker` that tracks the allocations and detects the mem leaks.  
                            Does not depend on anything of our code.  

**utils.cpp**               Implements `quantum__rt__fail()`, `quantum__rt__memory_allocate()`, `quantum__rt__heap_{alloc,free}()`.  
                            `quantum__rt__heap_alloc()` calls **strings.cpp**'s `quantum__rt__string_create()` - cyclical dependency.  

**strings.cpp**             Implements `QirString`, `quantum__rt__string_*()`, `quantum__rt__<type>_to_string()` (except `qubit_to_string` and `result_to_string`).  
                            Depends on **utils.cpp**'s `quantum__rt__fail()` - cyclical dependency.  


## Level 2
**allocationsTracker.cpp**  Implements the internals of `Microsoft::Quantum::AllocationsTracker`.  
                            Depends on `quantum__rt__fail()`, `quantum__rt__string_create()`  

**context.cpp**             Implements the internals of `Microsoft::Quantum::QirExecutionContext`,  
                            Depends on **allocationsTracker.hpp**'s `Microsoft::Quantum::AllocationsTracker`.  
                            Gets/returns `IRuntimeDriver *`.

## Level 3
**delegated.cpp**           Implements `quantum__rt__result_*()`, `quantum__rt__qubit_{allocate,release,to_string}()`.  
                            Each API depends on `Microsoft::Quantum::GlobalContext()[->GetDriver()]`,  
                            `quantum__rt__qubit_to_string()`  also depends on strings.cpp's `quantum__rt__string_create()`.  
                            `quantum__rt__result_to_string()` also depends on strings.cpp's `quantum__rt__string_create()`.  

**arrays.cpp**              Implements {the internals of `QirArray`} and `quantum__rt__*array*`.  
                            Depends on `Microsoft::Quantum::GlobalContext()`, `quantum__rt__fail()`, `quantum__rt__string_create()`,  
                            **delegated.cpp**'s `quantum__rt__qubit_allocate()`  

## Level 4
**callables.cpp**           Defines the {internals of `QirTupleHeader`, `QirCallable`}, `quantum__rt__tuple_*()`, `quantum__rt__callable_*()`  
                            Depends on `QirArray`, `Microsoft::Quantum::GlobalContext()`, `quantum__rt__fail()`, `quantum__rt__string_create()`, `TupleWithControls`,  
                            Consider breaking up into **Tuples.cpp** and **Callables.cpp**.

## Level 5
**bridge-rt.ll**            Defines the `@__quantum__rt__*` entry points (to be called by the `.ll` files generated from users' `.qs` files).  
                            The C++ Standard reserves the identifiers starting with double underscores `__`, that is why the definitions of `@__quantum__rt__*`
                            have been put to `.ll` file rather than `.cpp` file.  
                            Depends on `quantum__rt__*` implementations (in **utils.cpp**, **strings.cpp**, **delegated.cpp**, **arrays.cpp**, **callables.cpp**).
