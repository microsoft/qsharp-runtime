# Resource Tracer Design Document #

The purpose of the Resource Tracer is to provide efficient and flexible way to estimate resources of a quantum program
 in QIR representation. The estimates are calculated by simulating execution of the program (as opposed to the static
 analysis). Please see [Resource Estimator](https://docs.microsoft.com/en-us/azure/quantum/user-guide/machines/resources-estimator)
 for more background on resource estimation for quantum programs.

To run against the tracer, the quantum program should comply with the
 [QIR specifications](https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR) as well as:

1. convert _each_ used intrinsic operation into one of the Quantum Instruction Set (_qis_) operations supported by the
 tracer (see the last section of this readme);
1. (_optional_) provide callbacks for handling of conditional branches on a measurement (if not provided, the estimates
 would cover only one branch of the execution);
1. (_optional_) provide callbacks for start/end of quantum operations (if not provided, all operations will be treated
 as inlined as if the whole program consisted of a single operation);
1. (_optional_) provide callbacks for global barriers;
1. (_optional_) provide description of mapping for frame tracking;
1. (_optional_) provide names of operations for output (in the form of `tracer-config.hpp|cpp` files).

The Resource Tracer will consist of:

1. the bridge for the `__quantum__qis__*` methods listed below;
2. the native implementation to back the `__quantum__qis__*` methods;
3. the logic for partitioning gates into layers;
4. the logic for frame tracking;
5. output of the collected statistics;
6. (_lower priority_) the scheduling component to optimize depth and/or width of the circuit.

## Layering ##

One of the goals of the tracer is to compute which of the quantum operations can be executed in parallel. Further in
 this section we provide the defintions of used concepts and the description of how we group the operations into
 _layers_, however, we hope that the following example of layering is intuitively clear.

### Example of layering ###

The diagram below shows an example of how a sequential program, represented by the left circuit, could be layered. The gates in light gray are of duration zero, the preferrred layer duration is 1, and the barrier,
 represented by a vertical squiggle, is set to have duration 0.

![layering example](layering_example.png?raw=true "Layering example diagram")

Notice, that gate 9 is dropped because it cannot cross the barrier to be added into L(2,1).

### Definitions ###

Each quantum operation in a program can be assigned an integer value,  which we'll call its ___start time___. Some
 operations might have non-zero duration, so they will also have ___end time___. For each qubit, there are also times
 when the qubit is allocated and released. Start time of a gate cannot be less than allocation time of any of the qubits
 the gate is using. If two gates or measurements use the same qubit, one of the gates must have start time greater than
 or equal to the end time of the other. We'll call a particular assignment of times across a program its ___time function___.

A sequentially executed quantum program can be assigned a trivial time function, when all quantum operations have
 duration of 1 and unique start times, ordered to match the flow of the program. Layering compresses the timeline by
 assuming that some operations might be executed simultaneously while allowing for different operations to have various
 durations.

Provided a valid _time_ function for the program a ___layer of duration N at time T, denoted as L(T,N),___
 is a subset of operations in the program such that all of these operations have start time greater or equal _T_ and
 finish time less than _T + N_. The program is ___layered___ if all gates in it are partitioned into layers, that don't
 overlap in time. The union of all qubits that are involved in operations of a given layer, will be denoted _Qubits(T,N)_.

A sequential program can be trivially layered such that each layer contains exactly one operation. Notice, that the
 definition of layer doesn't require the gates to be executed _in parallel_. For example, all gates in a fully sequential
 program can be also placed into a single layer L(0, infinity). Some gates might be considered to be very cheap and take
 zero time to execute, those gates can be added to a layer even if they act on the same qubit another gate in this layer
 is acting on and have to be executed sequentially within the layer.

### The Resource Tracer's Layering Algorithm ###

As the tracer is executing a sequential quantum program, it will compute a time function and corresponding layering
 using the _conceptual_ algorithm, described below (aka "tetris algorithm"). The actual implementation of layering might
 be done differently, as long as the resulting layering is the same as if running the conceptual algorithm.

A ___barrier___ is a layer that acts as if it was containing all currently allocated qubits and no operation can be added
 into it.

A user can inject _barriers_ by calling `__quantum__qis__global_barrier` function. The user can choose duration of
 a barrier which would affect start time of the following layers but no operations will be added to a barrier,
 independent of its duration.

__Conditional execution on measurement results__: The Tracer will execute LLVM IR's branching structures "as is",
 depending on the values of the corresponding variables at runtime. To enable estimation of branches that depend on a
 measurement result, the source Q# program will have to be authored in such a way that the Q# compiler will translate the
 conditionals into corresponding callbacks to the tracer. The tracer will add operations from _both branches_ into the
 layers it creates to compute the upper bound estimate.

The following operations are _not_ supported inside conditional callbacks and would cause a runtime failure:

- nested conditional callbacks;
- measurements;
- opening and closing operations of tracked frames (if tracking is set up).

__Caching__ (lower priority): It might be a huge perf win if the Resource Tracer could cache statistics for repeated
 computations. The Tracer will have an option to cache layering results per quantum module if the boundaries of modules
 are treated as barriers.

#### The conceptual algorithm ####

Note: The tracer assumes that the preferred layer duration is _P_.

1. The first encountered operation of duration _N_, where either _N > 0_ or the operation involves multiple qubits, is
 added into layer _L(0, max(P,N))_. The value of _conditional barrier_ variable on the tracer is set to 0.
1. When conditional callback is encountered, the layer _L(t,N)_ of the measurement that produced the result used in the
 conditional callback, is looked up and the _conditional barrier_ is set to _t + N_. At the end of the conditional callback
 _conditional barrier_ is reset to 0. (Effectively, no operations, conditioned on the result of a measurement, can happen
 before or in the same layer as the measurement, even if they don't involve the measured qubits.)
1. Suppose, there are already layers _L(0,N0), ... , L(k,Nk)_ and the operation being executed is a single-qubit _op_ of
 duration __0__ (controlled and multi-qubit operations of duration 0 are treated the same as non-zero operations).

    - Scan from [boundaries included] _L(k,Nk)_ to _L(conditional barrier, Nb)_ until find a layer _L(t,Nt)_
     such that _Q(t,Nt)_ contains the qubit of _op_.
    - Add _op_ into this layer.
    - If no such layer is found, add _op_ to the list of pending operations on the qubit.
    - At the end of the program still pending operations will be ignored.

1. Suppose, there are already layers _L(0,N0), ... , L(k,Nk)_ and the operation being executed is _op_ of duration _N > 0_
 or it involves more than one qubit.

    - Scan from [boundaries included] _L(k,Nk)_ to _L(conditional barrier,Nb)_ until find a layer _L(w,Nw)_
     such that _Qubits(w,Nw)_ contain some of _op_'s qubits.
    - If _L(w,Nw)_ is found and _op_ can be added into it without increasing the layer's duration, add _op_ into
     _L(w,Nw)_, otherwise set _w = conditional barrier_.
    - If _op_ hasn't been added to a layer, scan from [boundaries included] _L(w,Nw)_ to _L(k,Nk)_ until find
     a layer _L(t,Nt)_ such that _Qubits(t, Nt)_ don't contain any of the _op_'s qubits and _N <= Nt_.
    - If _L(t,Nt)_ is found, add _op_ into this layer.
    - If _op_ hasn't been added to a layer, add _op_ into a new layer _L(k+Nk, max(P, N))_.
    - Add the pending operations of all involved qubits into the same layer and clear the pending lists.

## Special handling of SWAP ##

The tracer will provide a way to handle SWAP as, effectively, renaming of the involved qubits. The users will have the
 choice of using the special handling versus treating the gate as a standard counted intrinsic.

## Frame tracking ##

A user might want to count differently operations that are applied in a different state. For example, if Hadamard gate
 is applied to a qubit and then Rz gate, a user might want to count it as if Rz were executed instead.
 The frame is closed when the state of the qubit is reset (in Hadamard's case, another Hadamard operator is applied to
 the qubit). The user will be able to register the required frame tracking with the tracer via a C++ registration
 callback.

The descriptor of the frame will contain the following information and will be provided to the Tracer when initializing
 it in C++.

- openingOp: the operation id that opens the frame on the qubits this operation is applied to
- closingOp: the operation id that closes the frame on the qubits this operation is applied to
- vector of: { bitmask_ctls, bitmask_targets, operationIdOriginal, operationIdMapped }

The closing operation will be ignored if the frame on the qubit hasn't been open. The bitmasks define which of the qubits
 should be in an open frame to trigger the mapping. For non-controlled operations the first mask will be ignored. To
 begin with, the tracer will support frame mapping for up to 8 control/target qubits.

__TBD__: C++ definitions of the structure above + the interface to register frame tracking with the Tracer.

## Output format ##

The tracer will have options to output the estimates into command line or into a file, specified by the user. In both
 cases the output will be in the same format:

- column separator is configurable (the regex expressions below use comma as separator)
- the first column specifies the time _t_ of a layer _L(t, n)_ or of a barrier
- the second column contains the optional name of the layer or the barrier
- the remaining columns contain counts per operation in the layer (all zeros in case of a barrier)

- The first row is a header row: `layer_id,name(,[0-9a-zA-Z]+)*`. The fragment `(,[0-9a-zA-Z]+)*` lists operation
 names or their ids if the names weren't provided by the user.
- The following rows contain statistics per layer: `[0-9]+,[a-zA-Z]*(,([0-9]*))*`.
- The rows are sorted in order of increasing layer time.
- Zero counts for the statistics _can_ be replaced with empty string.

The map of operation ids to names can be passed to the tracer's constructor as `std::unordered_map<OpId, std::string>`.
 The mapping can be partial, ids will be used in the ouput for unnamed operations.

Example of valid output:

```csv
layer_id,name,Y,Z,5
0,,0,1,0
1,,0,0,1
2,b,0,0,0
4,,0,1,0
8,,1,0,0
```

## Depth vs width optimizations ##

TBD but lower priority.

## List of `__quantum__qis__*` methods, supported by the Tracer ##

| Signature                                             | Description                                                  |
| :---------------------------------------------------- | :----------------------------------------------------------- |
| `void __quantum__qis__inject_barrier(i32 %id, i32 %duration)` | Function to insert a barrier. The first argument is the id of the barrier that can be used to map it to a user-friendly name in the output and the second argument specifies the duration of the barrier. See [Layering](#layering) section for details. |
| `void __quantum__qis__on_module_start(i64 %id)`    | Function to identify the start of a quantum module. The argument is a unique _id_ of the module. The tracer will have an option to treat module boundaries as barriers between layers and (_lower priority_) option to cache estimates for a module, executed multiple times. For example, a call to the function might be inserted into QIR, generated by the Q# compiler, immediately before the body code of a Q# `operation`. |
| `void __quantum__qis__on_module_end(i64 %id)`      | Function to identify the end of a quantum module. The argument is a unique _id_ of the module and must match the _id_ supplied on start of the module. For example, a call to the function might be inserted into QIR, generated by the Q# compiler, immediately after the body code of a Q# `operation`. |
| `void __quantum__qis__single_qubit_op(i32 %id, i32 %duration, %Qubit* %q)` | Function for counting operations that involve a single qubit. The first argument is the id of the operation. Multiple intrinsics can be assigned the same id, in which case they will be counted together. The second argument is duration to be assigned to the particular invocation of the operation. |
| `void __quantum__qis__multi_qubit_op(i32 %id, i32 %duration, %Array* %qs)` | Function for counting operations that involve multiple qubits.|
| `void __quantum__qis__single_qubit_op__ctl(i32 %id, i32 %duration, %Array* %ctls, %Qubit* %q)` | Function for counting controlled operations with single target qubit and `%ctls` array of controls. |
| `void __quantum__qis__multi_qubit_op__ctl(i32 %id, i32 %duration, %Array* %ctls, %Array* %qs)` | Function for counting controlled operations with multiple target qubits and `%ctls` array of controls. |
| `%Result* @__quantum__qis__single_qubit_measure(i32 %id, i32 %duration, %Qubit* %q)` | Function for counting measurements of a single qubit. The user can assign different operation ids for different measurement bases. |
| `%Result* @__quantum__qis__joint_measure(i32 %id, i32 %duration, %Array* %qs)` | Function for counting joint-measurements of qubits. The user can assign different operation ids for different measurement bases. |
| `void __quantum__qis__swap(%Qubit* %q1, %Qubit* %q2)` | See [Special handling of SWAP](#special-handling-of-swap) for details. |
| TODO: handling of conditionals on measurement results | |

_Note on operation ids_: The user is responsible for using operation ids in a consistent manner. Operations with the
 same id will be counted by the tracer as the _same_ operation, even accross invocations with different number of target
 qubits or when different functors are applied.

_Note on mapping Q# intrinsics to the methods above_: Q# compiler will support Tracer as a special target and will let
 the user to either choose some default mapping or specify their custom mapping. For example, see QIR-tracer tests in
 this project (`tracer-target.qs` specifies the mapping).

The Resource Tracer will reuse qir-rt library while implementing the qis methods specified above.
