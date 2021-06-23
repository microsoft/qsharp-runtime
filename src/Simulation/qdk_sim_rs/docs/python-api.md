# Using Experimental Simulators from Python

This module exposes the various data structures from this crate as Python objects, useful for embedding in Python programs.

Note that this module contains Python-specific functionality, and cannot be used directly from Rust.

> **ⓘ NOTE**: The Python API for this crate allows direct and low-level access to simulation data structures. This is distinct from using Python to run Q# programs on the experimental simulators implemented by this library. For details on how to use Python and Q# together with experimental simulators, please see documentation on the <https://github.com/microsoft/iqsharp> repository.

## Building the Python API

This crate automatically builds a Python extension module when compiled using the `python` Cargo feature. This module can be built into an installable Python package by using the `pip` command:

```bash
# Install the qdk_sim crate as a Python package.
pip install .

# Build this crate as a redistributable Python wheel, targeting the current
# host architecture.
pip wheel .
```

In both cases, `pip` will automatically discover and use your Rust toolchain to call `cargo build` and include its output in the Python package built from this crate.

## Importing and working with the Python API

Once installed using the above steps, the Python interface into the experimental simulators can be accessed as `import qdk_sim`. Doing so gives access to Python representations of different data structures in this crate. For example:

```python
>>> import qdk_sim
>>> noise_model = qdk_sim.NoiseModel.get_by_name("ideal_stabilizer")
>>> noise_model
<NoiseModel NoiseModel { initial_state: QubitSized { n_qubits: 1, data: Stabilizer(Tableau { n_qubits: 1, table: [[true, false, false],
 [false, true, false]], shape=[2, 3], strides=[3, 1], layout=Cc (0x5), const ndim=2 }) }, i: QubitSized { n_qubits: 1, data: Sequence([]) }, x: QubitSized { n_qubits: 1, data: ChpDecomposition([Hadamard(0), 
Phase(0), Phase(0), Hadamard(0)]) }, y: QubitSized { n_qubits: 1, data: ChpDecomposition([AdjointPhase(0), Hadamard(0), Phase(0), Phase(0), Hadamard(0), Phase(0)]) }, z: QubitSized { n_qubits: 1, data: ChpDecomposition([Phase(0), Phase(0)]) }, h: QubitSized { n_qubits: 1, data: ChpDecomposition([Hadamard(0)]) }, s: QubitSized { n_qubits: 1, data: ChpDecomposition([Phase(0)]) }, s_adj: QubitSized { n_qubits: 1, 
data: ChpDecomposition([AdjointPhase(0)]) }, t: QubitSized { n_qubits: 1, data: Unsupported }, t_adj: QubitSized { n_qubits: 1, data: Unsupported }, cnot: QubitSized { n_qubits: 1, data: ChpDecomposition([Cnot(0, 1)]) }, z_meas: ZMeasurement { pr_readout_error: 0.0 } }>
```

Many Python objects implemented by this crate offer `as_json` methods that can be used to convert experimental simulator data structures to built-in Python objects:

```python
>>> import json
>>> json.loads(qdk_sim.NoiseModel.get_by_name("ideal_stabilizer").as_json())
{'initial_state': {'n_qubits': 1, 'data': {'Stabilizer': {'n_qubits': 1, 'table': {'v': 1, 'dim': [2, 3], 'data': [True, False, False, False, True, False]}}}}, 'i': {'n_qubits': 1, 'data': {'Sequence': []}}, 'x': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'Hadamard': 0}, {'Phase': 0}, {'Phase': 0}, {'Hadamard': 0}]}}, 'y': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'AdjointPhase': 0}, {'Hadamard': 0}, {'Phase': 0}, {'Phase': 0}, {'Hadamard': 0}, {'Phase': 0}]}}, 'z': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'Phase': 0}, {'Phase': 0}]}}, 'h': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'Hadamard': 
0}]}}, 's': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'Phase': 0}]}}, 's_adj': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'AdjointPhase': 0}]}}, 't': {'n_qubits': 1, 'data': 'Unsupported'}, 't_adj': {'n_qubits': 1, 'data': 'Unsupported'}, 'cnot': {'n_qubits': 1, 'data': {'ChpDecomposition': [{'Cnot': [0, 1]}]}}, 'z_meas': {'ZMeasurement': {'pr_readout_error': 0.0}}}
```
