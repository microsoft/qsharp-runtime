# Resource Tracer Design Document #

The purpose of the Resource Tracer is to provide efficient and flexible way to estimate resources of a quantum program
 in QIR representation. The estimates are calculated by simulating execution of the program (as opposed to the static
 analysis). Please see [Resource Estimator](https://docs.microsoft.com/en-us/azure/quantum/user-guide/machines/resources-estimator)
 for more background on resource estimation for quantum programs.

To run against the tracer, the quantum program should comply with the
 [QIR specifications](https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR) as well as:

1. convert _each_ used intrinsic operation into one of the _qis_ operations supported by the tracer (see the list below);
1. (_optional_) provide callbacks for handling of conditional branches on a measurement (if not provided, the estimates
 would cover only one branch of the execution);
1. (_optional_) provide callbacks for start/end of quantum operations (if not provided, all operations will be treated
 as inlined as if the whole program consisted of a single operation);
1. (_optional_) provide callbacks for global barriers;
1. (_optional_) provide description of mapping for frame tracking;
1. (_optional_) provide names of operations for output (in the form of `tracer-config.hpp|cpp` files).

The last provisions  

The Resource Tracer will consist of:

1. the bridge for the `__quantum__qis__*` methods listed below;
2. the native implementation to back the `__quantum__qis__*` methods;
3. the logic for partitioning gates into layers;
4. the logic for frame tracking;
5. output of the collected statistics;
6. (_lower priority_) the scheduling component to optimize depth and/or width of the circuit.

## Layering ##

_Definition_: ___Time___ is an integer-valued function on all quantum operations in a program (gates, measurements,
 qubits allocation/release). For each gate there are start and end times. For each qubit, there are times when the qubit
 is allocated and released. Start time of a gate cannot be less than allocation time of any of the qubits the gate uses.
 If two gates or measurements use the same qubit, one of the gates must have start time greater than or equal to the end
 time of the other.

A sequentially executed quantum program can be assigned a trivial time function, when all quantum operations have
 duration of 1 and unique start times, ordered to match the flow of the program. Layering compresses the timeline by
 assuming that some operations might be executed simultaneously while allowing for different operations to have various
 durations.

_Definition_: Provided a valid _time_ function for the program a ___layer of duration N at time T, denoted as L(T,N),___
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

_Definition_: A ___barrier___ is a layer that no more operations can be added into.

A user will be able to inject global barriers by calling `__quantum__qis__global_barrier` function. The user can choose
 duration of a barrier which would affect start time of the following layers but no operations will be added to a barrier,
 independent of its width.

#### The conceptual algorithm ####

1. The tracer must be set the preferred layer duration: P.
1. The first encountered operation of __non-zero__ duration N is added into layer L(0, max(P,N)). The value
 of _conditional barrier_ variable on the tracer is set to 0.
1. When conditional callback is encountered, the layer L(t,N) of the measurement that produced the result the conditional
 is dependent on, is looked up and the _conditional barrier_ is set to _t + N_. At the end of the conditional scope
 _conditional barrier_ is reset to 0. (Effectively, no operations, conditioned on the result of a measurement, can happen
 before or in the same layer as the measurement, even if they don't involve the measured qubits.)
 TODO: is it OK for later operations to be added to the layers with ops _inside_ conditional branches?
1. Suppose, there are already layers L(0,N0), ... , L(k,Nk) and the operation being executed is a single-qubit _op_ of
 duration __0__ (controlled and multi-qubit operations of duration 0 are treated the same as non-zero operations).
 Starting at L(k, Nk) and scanning backwards to L(_conditional barrier_, Nb) find the _first_ layer that contains an
 operation that acts on the qubit of _op_. Add _op_ into this layer. If no such layer is found, add _op_ to the list of
 pending operations on the qubit. At the end of the program still pending operations are ignored.
1. Suppose, there are already layers L(0,N0), ... , L(k,Nk) and the operation being executed is _op_ of duration _N > 0_
 or it involves more than one qubit. Starting at L(k, Nk) and scanning backwards to L(_conditional barrier_, Nb) find the
 _last_ layer L(t, Nt) such that Qubits(t, Nt) don't contain any of the _op_'s qubits and find the _first_ layer L(w, Nw)
 such that Qubits(w, Nw) contains some of _op_'s qubits but Nw + N <= P. Add _op_ into one of the two layer with later
 time. If neither such layers is found, add _op_ into a new layer L(k+1, max(P, N)). Add the pending operations of all
 involved qubits into the same layer and clear the pending lists.

#### Example of layering ####

The diagram below shows an example of how a sequential program, represented by the left circuit, would be layered by the
 algorithm above. The gates in light gray are of duration zero, the preferrred layer duration is 1, and the barrier,
 represented by a vertical squiggle, is set to have duration 0.

![layering example](layering_example.png?raw=true "Layering example diagram")

Notice, that gate 9 is dropped because it cannot cross the barrier to be added into L(2,1).

## Special handling of SWAP ##

The tracer will provide a way to handle SWAP as, effectively, renaming of the involved qubits. The users will have the
 choice of using the special handling versus treating the gate as a standard counted intrinsic.

## Frame tracking ##

A user might want to count differently operations that are applied in a different state. For example, if Hadamard gate
 is applied to a qubit and then Rz and Mx gates, a user might want to count the sequence as if Rz as Mz were executed.
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

- Tab separated, where:

  - the first column specifies the time _t_ of a layer _L(t, n)_
  - the second column contains an optional name of the layer, that corresponds to a global barrier
  - the remaining columns contain counts per operation in the layer

- The first row is a header row: `layer_id\tname(\t[a-zA-Z]+)*`, where specific operation names are listed, such as
 CNOT, Mz, etc., if provided by the user (if not provided, the header row will list operation ids).
- All following rows contain statistics per layer: `[0-9]+\t[a-zA-Z]*(\t([0-9]*))*`.
- The rows are sorted in order of increasing layer time.
- Zero counts for any of the statistics _might_ be replaced with empty string.
- The global barrier layer lists the name and no statistics.

The map of operation ids to names can be passed to the tracer's constructor as `std::unordered_map<OpId, std::string>`.
 The mapping can be partial, ids will be used in the ouput for unnamed operations.

## Depth vs width optimizations ##

TBD but lower priority.

## List of `__quantum__qis__*` methods, supported by the Tracer ##

| Signature                                             | Description                                                  |
| :---------------------------------------------------- | :----------------------------------------------------------- |
| `void __quantum__qis__inject_global_barrier(i32 %id, i32 %duration)` | Function to insert a global barrier between layers. The first argument is the id of the barrier and the second item specifies the duration of the barrier. See [Layering](#layering) section for details. |
| `void __quantum__qis__on_module_start(i64 %id)`    | Function to identify the start of a quantum module. The argument is a unique _id_ of the module. The tracer will have an option to treat module boundaries as barriers between layers and (_lower priority_) option to cache estimates for a module, executed multiple times. For example, a call to the function might be inserted into QIR, generated by the Q# compiler, immediately before the body code of a Q# `operation`. |
| `void __quantum__qis__on_module_end(i64 %id)`      | Function to identify the end of a quantum module. The argument is a unique _id_ of the module and must match the _id_ supplied on start of the module. For example, a call to the function might be inserted into QIR, generated by the Q# compiler, immediately after the body code of a Q# `operation`. |
| `void __quantum__qis__single_qubit_op(i32 %id, i32 %duration, %Qubit* %q)` | Function for counting operations that involve a single qubit. The first argument is the id of the operation. Multiple intrinsics can be assigned the same id, in which case they will be counted together. The second argument is duration to be assigned to the particular invocation of the operation. |
| `void __quantum__qis__multi_qubit_op(i32 %id, i32 %duration, %Array* %qs)` | Function for counting operations that involve multiple qubits.|
| `void __quantum__qis__single_qubit_op__ctl(i32 %id, i32 %duration, %Array* %ctls, %Qubit* %q)` | Function for counting controlled operations with single target qubit. |
| `void __quantum__qis__multi_qubit_op__ctl(i32 %id, i32 %duration, %Array* %ctls, %Array* %qs)` | Function for counting controlled operations with multiple target qubits. |
| `%Result* @__quantum__qis__single_qubit_measure(i32 %id, i32 %duration, %Qubit* %q)` | Function for counting measurements of a single qubit. The user might assign different operation ids for different measurement bases. |
| `%Result* @__quantum__qis__joint_measure(i32 %id, i32 %duration, %Array* %qs)` | Function for counting joint-measurements of qubits. The user might assign different operation ids for different measurement bases. |
| `void __quantum__qis__swap(%Qubit* %q1, %Qubit* %q2)` | See [Special handling of SWAP](#special-handling-of-swap) for details. |
| TODO: handling of conditionals on measurement results | |

_Note on operation ids_: The user is responsible for using operation ids in a consistent manner. Operations with the
 same id will be counted by the tracer as the _same_ operation, even accross invocations with different number of target
 qubits or when different functors are applied.

_Note on mapping Q# intrinsics to the methods above_: Q# compiler will support Tracer as a special target and will let
 the user to either choose some default mapping or specify their custom mapping. For example, see QIR-tracer tests in
 this project (`tracer-target.qs` specifies the mapping).

The Resource Tracer will reuse qir-rt library while implementing the qis methods specified above.

__Conditionals on measurements__: The Resource Tracer will execute LLVM IR's branching structures "as is", depending on
 the values of the corresponding variables at runtime. To enable estimation of branches that depend on a measurement
 result, the source Q# program will have to be authored in such a way that the Q# compiler will translate the
 conditionals into `__quantum__qis__apply_if*` calls. The tracer will add operations from _both branches_ into the
 layers it creates to compute the upper bound estimate.

Nested conditionals, conditional measurements and conditional tracked operations will _not_ be supported.

__Caching__ (lower priority): It might be a huge perf win if the Resource Tracer could cache statistics for repeated
 computations. The Tracer will have an option to cache layering results per quantum module if the boundaries of modules
 are treated as layering barriers.