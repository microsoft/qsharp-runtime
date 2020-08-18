# Code Generator for Quantum Targets

## What is this for?

This project contains a Q# compiler extension (rewrite step) that looks for
all of the intrinsic functions and operations defined in the current Q#
compilation and uses them to generate a C# abstract base class for a target
that implements those intrinsics.
Each intrinsic turns into both an inner class and one or more abstract methods
in the abstract base class.
In order to implement a simulator, emulator, or other target, a developer can
simply create a concrete implementation class that inherits from the generated
abstract base class and implements the abstract methods.

## How do I use it?

1. Create a Q# project that lists all of the intrinsic operations and
   functions to be provided by the simulator.
1. Compile the project with this rewrite step, which will create a C# file
   defining the abstract base class. 
1. Copy that file into your target C# project. This can be done in a 
   post-build step for convenience.
1. Write add another file that defines a subclass of the abstract base that
   implements all of the abstract "Do*" methods in the base.
1. Compile that C# project into the new simulator/emulator/target.

The new simulator class can be used just like any other simulator such as
`QuantumSimulator`.

## How do I control it?

This rewrite step is controlled by the following assembly constants:

- TargetClass is required; it holds the fully-qualified name of the class to
  generate.
- TargetToExtend is optional. If provided, it should be the fully-qualified
  name of the class the generated class should inherit from; otherwise, the
  generated class will inherit from SimulatorBase.
- CustomQubitManagement is optional. If provided and set to `true`, then
  overrides for Allocate, Release, Borrow, and Release will be generated in
  the target class. Otherwise, the base class's default behavior is used; for
  SimulatorBase, the default is to pass these through to the qubit manager.
- CustomStateDump is optional. If provided and set to `true`, or if no 
  TargetToExtend is provided, then overrides for DumpMachine and DumpRegister
  will be generated in the target class. Otherwise, the base class's default
  behavior is used.

## Sample Scenarios

Here we provide more details on using this rewrite step for some common
scenarios.

### New simulator

To build a new simulator:

The target definition Q# file should specify all of the operations and
functions that the simulator will implement directly, all with `intrinsic`
implementations.
The file "Intrinsic.qs" from the `Microsoft.Quantum.Qsharp.Core` project may
be useful as a base or as the target definition file directly.

`TargetToExtend` should be left out.
`CustomQubitManagement` should be set to `true` if the standard qubit manager's
behavior needs to be overridden or modified.
`CustomStateDump` can be set to `true` or simply left out.

### Emulator

To build an emulator that extends an existing simulator with an optimized
version of a higher-level operation:

The target definition Q# file should specify only the operation(s) that are to
be emulated.

`TargetToExtend` should be the fully-qualified name of the base simulator
class you are extending.
`CustomQubitManagement` should be left out.
`CustomStateDump` should be left out.

### Extended dump capabilities

You could use this approach to build a new simulator based on an existing one
that has a different dump format:

The target definition Q# file should not define any functions or operations.

`TargetToExtend` should be the fully-qualified name of the base simulator
class you are extending.
`CustomQubitManagement` should be left out.
`CustomStateDump` should be set to `true`.
