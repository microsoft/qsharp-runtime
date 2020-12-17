# Resource Tracer Design Document #

The purpose of the Resource Tracer is to provide efficient and flexible way to estimate resources of a quantum program in QIR representation.

In addition to the standard QIR runtime functions, the program will have to:

1. provide callbacks for handling of conditional branches on a measurement (signature: TBD);
2. provide callbacks for start/end of a quantum operations (`void __quantum__ext__on_operation_start(%i64 %id)` and `void __quantum__ext__on_operation_start(%i64 %id)`);
3. convert the intrinsic gates that should be counted into one of the supported by the tracer _bucketing_ operations (along the line of `void __quantum__ext__gate_type_1(%i32 %weight)`, ... , `void __quantum__ext__gate_type_12(%i32 %weight)`).

Choosing the Resource Tracer as the target druing Q# compilation, will take care of requirements 1 and 2 above, the user will have to specify the bucketing in 3 via a custom target.qs file.

The Resource Tracer will consist of:

1. the bridge for the `__quantum__ext__*` extension methods;
2. the native implementation to back the extension;
3. partitioning gates into layers;
4. special handling of Hadamard and SWAP gates;
5. output of the collected statistics;
6. (_lower pri_) the scheduling component to optimize depth and/or width of the circuit.

## List of required `__quantum__ext__*` methods ##

TBD

## Native backing of the extension methods ##

To enable maximum optimizations by LLVM, the Resource Tracer won't rely on the simulator interfaces and instead will implement all extensions directly, without any virtualization. The Resource Tracer will reuse qir-rt library for everything but qubit and result management (the qir-rt library might need to be refactored to allow for a different implementation of these delegated methods).

__Conditionals on measurements__: The Resource Tracer will execute LLVM IR's branching structures "as is", depending on the values of the corresponding variables at runtime. To enable estimation of branches that depend on a measurement result, the source Q# program will have to be authored in a compatible way and the Q# compiler will translate the conditionals into `__quantum__ext__apply_if*` calls. The tracer will add operations from _both branches_ into the layers it creates.

To begin with, no nested conditionals and no conditional measurements/Hadamard gates will be supported.

__Caching__ (lower priority): It might be a huge perf win if the Resource Tracer could cache statistics for repeated computations. However, the caching doesn't seem tenable if statistics _by layer_ are required. We might consider providing a "sketch" mode for the tracer without layering...

## Layering of gates ##

_Definition_: ___Time___ is a real-valued function on all quantum operations in a program (gates, measurements, qubits allocation/release). For each gate there is start and end times. For each qubit, there are times when the qubit is allocated and released. Start time of a gate cannot be less than allocation time of any of the qubits the gate uses. If two gates use the same qubit, one of the gates must have start time greater of equal than the end time of the other.

A sequentially executed quantum program has a trivial time function associated with it, when all quantum operations have duration of 1 and unique start times, ordered to match the flow of the program. Layering compresses the timeline by assuming that some gates might be executed simultaneously.

_Definition_: Provided a valid _time_ function for the program a ___layer of width N at time T___ is a subset of gates in the program such that all of these gates have start time greater or equal _T_ and finish time less than _T + N_. We'll denote a layer as _L(T,N)_. The program is ___layered___ if all gates in it are partitioned into non-overlapping by time layers.

A sequential program can be trivially layered such that each layer contains exactly one operation. Notice, that the definition of layer doesn't require the gates to be executed _in parallel_. For example, all gates in a fully sequential program can be placed in layer L(0, infinity). Some gates might be considered to be very cheap and take zero time to execute, those gates can be added to the same layer even if they act on the same qubit and have to be executed sequentially within the layer.

_Definition_: A ___global barrier___ is an identity operation on _all_ qubits that takes time 1. It can be inserted by the programmer to enforce a particular layering structure (because no following operation can sink below the barrier).

### The Resource Tracer's Layering Algorithm ###

As the tracer is executing a sequential quantum program, it will compute a time function and corresponding layering using the following ("tetris") algorithm:

1. All layers have width one (so we'll shorten the layer notation from L(t, 1) to L(t)).
2. All gates have duration either 0 or 1, as specified by the user.
3. The first encountered operation is assigned time 0 and added into layer L(0);
4. Suppose, already have layers L(0), ... , L(k) and the operation being executed is _op_ of width __0__. Starting at L(k) and going backwards to L(0) find the _first_ layer that contains a gate that acts on at least one of the qubits _op_ is acting on. Add _op_ into this layer. If no such layer found, add _op_ into L(0). Notice, that operations of width 0 never trigger creation of new layers.
5. Suppose, already have layers L(0), ... , L(k) and the operation being executed is _op_ of width __1__. Starting at L(k) and going backwards to L(0) find the _last_ layer that does not contain gates that act on any of the qubits _op_ is acting on. Add _op_ into this layer. If no such layer found, assign _op_ time _k+1_ and add it into a new layer L(k+1).

## Tracking of Hadamard and SWAP gates ##

TBD

## Output format ##

Need to coordinate with the [Python Estimation Tool](https://ms-quantum.visualstudio.com/Quantum%20Architecture/_git/ResourceEstimation) (AlgorithmLayers.py defines format).

Can we store enough information about the gates to remap the buckets back to individual gates for the purposes of user friendly output? Could QIR add some kind of "registration" methods, based on the target.qs file?

TBD: describe the format formally

## Depth vs width optimizations ##

TBD but lower priority.
