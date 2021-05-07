# Directory Structure

https://github.com/microsoft/qsharp-runtime/pull/476

Q# defines the set of basic gate operations in the Microsoft.Quantum.Intrinsic namespace, 
where the fundamental operations are implemented as body intrinsic 
and other operations are expressed as decompositions onto these body-intrinsic operations. 
These effectively represent a specific quantum gate set that the current version of the simulator implements. 
To facilitate experimentation, testing, and eventually targeting of simulators and hardware with a different quantum gate set,
the runtime should have infrastructure and examples of alternate implementations of operations 
in the Microsoft.Quantum.Intrinsic namespace as decompositions 
on top of the body-intrinsic operations for that alternate gate set.

## **QSharpFoundation**
The QSharpFoundation project includes those fundamental elements of the language 
that all decomposition packages rely on, while the implementation that remains in QSharpCore 
is expected to be overridden/replaced with alternative implementation defined in a specific decomposition package.
Contains common implementations shared across all target packages.

## **QSharpCore**
QSharpCore is built on top of QSharpFoundation.


# See Also
[TargetDefinitions/README.md](TargetDefinitions/README.md )
