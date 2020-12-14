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
4. (_lower pri_) the scheduling component to optimize depth and/or width of the circuit.

## List of supported `__quantum__ext__*` methods ##

TBD

## Native backing of the extension methods ##

To enable maximum optimizations by LLVM, the Resource Tracer won't rely on the simulator interfaces and instead will implement all extensions directly, without any virtualization. The Resource Tracer will reuse qir-rt library for everything but qubit and result management (the qir-rt library will be refactored to allow for a different implementation of these delegated methods).

## Layering of gates ##

TBD

## Depth vs width optimizations ##

TBD