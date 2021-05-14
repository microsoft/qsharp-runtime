This **experimental** crate contains simulation functionality for the Quantum Development Kit, including:

- Open systems simulation
- Stabilizer simulation

The [`c_api`] module allows for using the simulation functionality in this crate from C, or from other languages with a C FFI (e.g.: C++ or C#), while Rust callers can take advantage of the structs and methods in this crate directly.

## Cargo Features

- **`doc`**: Required to build documentation.
- **`python`**: Enables Python bindings for this crate.
- **`wasm`**: Ensures that the crate is compatible with usage from WebAssembly.

## Representing open quantum systems

This crate provides several different data structures for representing open quantum systems in a variety of different conventions:

- [`State`]\: Represents pure or mixed states of a register of qubits.
- [`Process`]\: Represents processes that map states to states.
- [`Instrument`]\: Represents quantum instruments, the most general form of measurement.

## Noise model serialization

TODO
