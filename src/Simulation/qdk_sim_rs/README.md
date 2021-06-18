<!-- NB: This README is formatted for use with `cargo doc`, and makes use of
         rustdoc-specific extensions to Markdown.

         To generate and view the documentation for this crate locally, please
         run:

         $ cargo +nightly doc --features python --open
-->

# Quantum Development Kit Experimental Simulators

> ## **⚠** WARNING **⚠**
>
> This crate is **experimental**, and may undergo breaking API changes with no notice, and may not be maintained in future versions of the Quantum Development Kit.
>
> As an experimental feature of the Quantum Development Kit, this crate may be buggy or incomplete. Please check the tracking issue at [microsoft/qsharp-runtime#714](https://github.com/microsoft/qsharp-runtime/issues/714) for more information.

> ## **ⓘ** TIP
>
> This crate provides low-level APIs for interacting with experimental simulators. If you're interested in using the experimental simulators to run your Q# programs, please see the installation instructions at <https://github.com/microsoft/qsharp-runtime/tree/feature/experimental/opensim/documentation/experimental-simulators.md>.

This **experimental** crate implements simulation functionality for the Quantum Development Kit, including:

- Open systems simulation
- Stabilizer simulation

The [`c_api`] module allows for using the simulation functionality in this crate from C, or from other languages with a C FFI (e.g.: C++ or C#), while Rust callers can take advantage of the structs and methods in this crate directly.

Similarly, the [`python`] module allows exposing data structures in this crate to Python programs.

## Cargo Features

- **`python`**: Enables Python bindings for this crate.
- **`wasm`**: Ensures that the crate is compatible with usage from WebAssembly.

## Representing quantum systems

This crate provides several different data structures for representing quantum systems in a variety of different conventions:

- [`State`]\: Represents stabilizer, pure, or mixed states of a register of qubits.
- [`Process`]\: Represents processes that map states to states.
- [`Instrument`]\: Represents quantum instruments, the most general form of measurement.

## Noise model serialization

Noise models can be serialized to JSON for interoperability across languages. In particular, each noise model is represented by a JSON object with properties for each operation, for the initial state, and for the instrument used to implement $Z$-basis measurement.

For example:

```json
{
    "initial_state": {
        "n_qubits": 1,
        "data": {
            "Mixed": {
                "v": 1, "dim":[2 ,2],
                "data": [[1.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
            }
        }
    },
    "i": {
        "n_qubits": 1,
        "data": {
            "Unitary": {
                "v": 1,"dim": [2, 2],
                "data": [[1.0, 0.0], [0.0, 0.0], [0.0, 0.0], [1.0, 0.0]]
            }
        }
    },
    ...
    "z_meas": {
        "Effects": [
            {
                "n_qubits": 1,
                "data": {
                    "KrausDecomposition": {
                        "v":1, "dim": [1, 2, 2],
                        "data": [[1.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
                    }
                }
            },
            {
                "n_qubits": 1,
                "data": {
                    "KrausDecomposition": {
                        "v": 1,"dim": [1, 2, 2],
                        "data":[[0.0, 0.0], [0.0, 0.0], [0.0, 0.0], [1.0, 0.0]]
                    }
                }
            }
        ]
    }
}
```

The value of the `initial_state` property is a serialized [`State`], the value of each operation property (i.e.: `i`, `x`, `y`, `z`, `h`, `s`, `s_adj`, `t`, `t_adj`, and `cnot`) is a serialized [`Process`], and the value of `z_meas` is a serialized [`Instrument`].

### Representing arrays of complex numbers

Throughout noise model serialization, JSON objects representing $n$-dimensional arrays of complex numbers are used to store various vectors, matrices, and tensors. Such arrays are serialized as JSON objects with three properties:

- `v`: The version number of the JSON schema; must be `"1"`.
- `dims`: A list of the dimensions of the array being represented.
- `data`: A list of the elements of the flattened array, each of which is represented as a list with two entries representing the real and complex parts of each element.

For example, consider the serialization of the ideal `y` operation:

```json
"y": {
    "n_qubits": 1,
    "data": {
        "Unitary": {
            "v": 1, "dim": [2, 2],
            "data": [[0.0, 0.0], [0.0, 1.0], [0.0, -1.0], [0.0, 0.0]]
        }
    }
}
```

### Representing states and processes

Each state and process is represented in JSON by an object with two properties, `n_qubits` and `data`. The value of `data` is itself a JSON object with one property indicating which variant of the [`StateData`] or [`ProcessData`] enum is used to represent that state or process, respectively.

For example, the following JSON object represents the mixed state $\ket{0}\bra{0}$:

```json
{
    "n_qubits": 1,
    "data": {
        "Mixed": {
            "v": 1, "dim":[2 ,2],
            "data": [[1.0, 0.0], [0.0, 0.0], [0.0, 0.0], [0.0, 0.0]]
        }
    }
}
```

### Representing instruments

TODO

## Known issues

- Performance of open systems simulation still needs additional work for larger registers.
- Some gaps in different conversion functions and methods.
- Stabilizer states cannot yet be measured through [`Instrument`] struct, only through underlying [`Tableau`].
- Many parts of the crate do not yet have Python bindings.
- Stabilizer simulation not yet exposed via C API.
- Test and microbenchmark coverage still incomplete.
- Too many APIs `panic!` or `unwrap`, and need replaced with `Result` returns instead.
