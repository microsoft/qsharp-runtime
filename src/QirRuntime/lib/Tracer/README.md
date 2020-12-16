# Resource Tracer Design Document #

The purpose of the Resource Tracer is to provide efficient and flexible way to estimate resources of a quantum program in QIR representation.

In addition to the standard QIR runtime functions, the program will have to:

1. provide callbacks for handling of conditional branches on a measurement (signature: TBD);
2. provide callbacks for start/end of a quantum operations (`void __quantum__ext__on_operation_start(%i64 %id)` and `void __quantum__ext__on_operation_start(%i64 %id)`);
3. convert intrinsic gate calls into one of the supported by the tracer _bucketing_ operations (along the line of `void __quantum__ext__gate_type_1(%i32 %weight)`, ... , `void __quantum__ext__gate_type_12(%i32 %weight)`).

Choosing the Resource Tracer as the target druing Q# compilation, will take care of requirements 1 and 2 above, the user will have to specify the bucketing in 3 via a custom target.qs file.

The Resource Tracer will consist of:

1. the bridge for the `__quantum__ext__*` extension methods;
2. the native implementation to back the extension;
3. the component for partitioning gates into layers;
4. the component for output of the collected statistics
5. (_lower pri_) the scheduling component to optimize depth and/or width of the circuit.

## List of required `__quantum__ext__*` methods ##

TBD

## Native backing of the extension methods ##

To enable maximum optimizations by LLVM, the Resource Tracer won't rely on the simulator interfaces and instead will implement all extensions directly, without any virtualization. The Resource Tracer will reuse qir-rt library for everything but qubit and result management (the qir-rt library will be refactored to allow for a different implementation of these delegated methods).

__Conditionals on measurements__: The Resource Tracer will execute LLVM IR's branching structures "as is", depending on the values of the corresponding variables at runtime. To enable estimation of branches that depend on a measurement result, the source Q# program will have to be authored in a compatible way and the Q# compiler will translate the conditionals into `__quantum__ext__apply_if*` calls. The runtime will execute _both_ branches and report the estimate for the worst case scenario (TBD: worst by what measure? by depth? by overall weight? by a particular gate bucket?).

__Caching__: It might be a huge perf win if the Resource Tracer could cache statistics for repeated computations. It helps that the statistics won't depend on the state of the qubits, so only classical parameters need to be taken into account.

## Layering of gates ##

TBD

Should the layers be allowed to span multiple Q# operations (QIR functions)?
Should there be an explicit "barrier" that the user can specify in Q# to break a layer?
What is the layering algorithm?

## Output format ##

Need to coordinate with the [Python Estimation Tool](https://ms-quantum.visualstudio.com/Quantum%20Architecture/_git/ResourceEstimation) (AlgorithmLayers.py defines format).

Can we store enough information about the gates to remap the buckets back to individual gates for the purposes of user friendly output? Could QIR add some kind of "registration" methods, based on the target.qs file?

TBD: formal description of the format (json?)

## Depth vs width optimizations ##

TBD but lower priority.
