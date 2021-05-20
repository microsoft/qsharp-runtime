# Quantum Development Kit Experimental Simulators

> ## **⚠** WARNING **⚠**
>
> This crate is **experimental**, and may undergo breaking API changes with no notice, and may not be maintained in future versions of the Quantum Development Kit.
>
> As an experimental feature of the Quantum Development Kit, this crate may be buggy or incomplete. Please check the tracking issue at [microsoft/qsharp-runtime#504](https://github.com/microsoft/qsharp-runtime/issues/504) for more information.

This **experimental** crate contains simulation functionality for the Quantum Development Kit, including:

- Open systems simulation
- Stabilizer simulation

The [`c_api`] module allows for using the simulation functionality in this crate from C, or from other languages with a C FFI (e.g.: C++ or C#), while Rust callers can take advantage of the structs and methods in this crate directly.

## Cargo Features

- **`doc`**: Enables building documentation (requires `+nightly`).
- **`python`**: Enables Python bindings for this crate.
- **`wasm`**: Ensures that the crate is compatible with usage from WebAssembly.

## Representing quantum systems

This crate provides several different data structures for representing quantum systems in a variety of different conventions:

- [`State`]\: Represents stabilizer, pure, or mixed states of a register of qubits.
- [`Process`]\: Represents processes that map states to states.
- [`Instrument`]\: Represents quantum instruments, the most general form of measurement.

## Noise model serialization

TODO

## Known issues

- Performance of open systems simulation still needs additional work for larger registers.
- Some gaps in different conversion functions and methods.
- Stabilizer states cannot yet be measured through [`Instrument`] struct, only through underlying [`Tableau`].
- Many parts of the crate do not yet have Python bindings.
- Stabilizer simulation not yet exposed via C API.
- Test and microbenchmark coverage still incomplete.
- Too many APIs `panic!` or `unwrap`, and need replaced with [`std::Result`] returns instead.
