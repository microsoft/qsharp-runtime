# Using Experimental Simulators from C

This module exposes a C API for this crate, useful for embedding into simulation
runtimes.

## Safety

As this is a foreign-function interface, many of the functions exposed here
are **unsafe**, representing that the caller is required to ensure that safety
conditions in the host language are upheld.

Please pay attention to any listed safety notes when calling into this C
API.

## Generating and Using C API Headers

The [`qdk_sim`](..) crate has enabled the use of [`cbindgen`](https://crates.io/crates/cbindgen), such that C-language header files are generated automatically as part of the build for this crate.

```bash
cargo install --force cbindgen
cbindgen --language C --output include/qdk_sim.h
cbindgen --language C++ --output include/qdk_sim.hpp
```

This will generate `include/qdk_sim.h` and `include/qdk_sim.hpp`, which can then be used from C and C++ callers, respectively. For example, to call from C:

```c
#include <stdio.h>
#include "qdk_sim.h"

int main() {
    uintptr_t sim_id;
    uintptr_t result0, result1;

    init(2, "mixed", &sim_id);
    h(sim_id, 0);
    h(sim_id, 1);

    m(sim_id, 0, &result0);
    m(sim_id, 1, &result1);

    printf("got %llu %llu", result0, result1);
    destroy(sim_id);
}
```

To build and run the above example using Clang on Windows:

```bash
$ clang example.c -Iinclude -Ltarget/debug -lqdk_sim -lws2_32 -lAdvapi32 -lUserenv
$ ./a.exe
got 1 1
```

## Error Handling and Return Values

Most C API functions for this crate return an integer, with `0` indicating success and any other value indicating failure. In the case that a non-zero value is returned, API functions will also set the last error message, accessible by calling [`lasterr`]:

```c
#include <stdio.h>
#include "qdk_sim.h"

int main() {
    uintptr_t sim_id;
    uintptr_t result0, result1;

    if (init(2, "invalid", &sim_id) != 0) {
        printf("Got an error message: %s", lasterr());
    } else {
        destroy(sim_id);
    }
}
```

C API functions that need to return data to the caller, such as [`m`], do so by accepting pointers to memory where results should be stored.

> **⚠ WARNING**: It is the caller's responsibility to ensure that pointers used to hold results are valid (that is, point to memory that can be safely written into).

For example:

```c
uintptr_t result;
if (m(sim_id, 0, &result) != 0) {
    printf("Got an error message: %s", lasterr());
} else {
    printf("Got a measurement result: %llu", result);
}
```

## Initializing, Using, and Destroying Simulators

To create a new simulator from C, use the [`init`] function. This function accepts a pointer to an unsigned integer that will be set to an ID for the new simulator:

```c
uintptr_t sim_id;
// Initialize a new simulator with two qubits and using a mixed-state
// representation.
if (init(2, "mixed", &sim_id) != 0) {
    printf("Error initializing simulator: %s", lasterr());
}
```

The ID for the newly created simulator can then be used to call into functions that apply different quantum operations, such as [`x`], [`h`], or [`cnot`]:

```c
// Apply an 𝑋 operation to qubit #0.
if (x(sim_id, 0) != 0) {
    printf("Error applying X: %s", lasterr());
}
```

To free the memory associated with a given simulator, use the [`destroy`] function:

```c
if (destroy(sim_id) != 0) {
    printf("Error destroying simulator: %s", lasterr());
}
```

## Getting and Setting Noise Models

Noise models for each simulator can be accessed or set by using [`get_noise_model`], [`get_noise_model_by_name`], [`set_noise_model`], and [`set_noise_model_by_name`]. Each of these functions accepts either a name of a built-in noise model (see [`crate::NoiseModel::get_by_name`] for details).

Noise models in the C API are represented by strings containing JSON serializations of the [`crate::NoiseModel`] data model. For example:

```c
#include <stdio.h>
#include "qdk_sim.h"

int main() {
    const char *noise_model;

    if (get_noise_model_by_name("ideal", &noise_model) != 0) {
        printf("Error getting noise model: %s", lasterr());
    }

    printf("Noise model:\n%s", noise_model);
}

```

Running the above results in the JSON representation of the ideal noise model being written to the console:

```text
Noise model:
{"initial_state":{"n_qubits":1,"data":{"Mixed":{"v":1,"dim":[2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]]}}},"i":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]]}}},"x":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[0.0,0.0],[1.0,0.0],[1.0,0.0],[0.0,0.0]]}}},"y":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[0.0,0.0],[0.0,1.0],[-0.0,-1.0],[0.0,0.0]]}}},"z":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[-1.0,-0.0]]}}},"h":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[0.7071067811865476,0.0],[0.7071067811865476,0.0],[0.7071067811865476,0.0],[-0.7071067811865476,-0.0]]}}},"s":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,1.0]]}}},"s_adj":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.0,-1.0]]}}},"t":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.7071067811865476,0.7071067811865476]]}}},"t_adj":{"n_qubits":1,"data":{"Unitary":{"v":1,"dim":[2,2],"data":[[1.0,-0.0],[0.0,-0.0],[0.0,-0.0],[0.7071067811865476,-0.7071067811865476]]}}},"cnot":{"n_qubits":2,"data":{"Unitary":{"v":1,"dim":[4,4],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0],[0.0,0.0]]}}},"z_meas":{"Effects":[{"n_qubits":1,"data":{"KrausDecomposition":{"v":1,"dim":[1,2,2],"data":[[1.0,0.0],[0.0,0.0],[0.0,0.0],[0.0,0.0]]}}},{"n_qubits":1,"data":{"KrausDecomposition":{"v":1,"dim":[1,2,2],"data":[[0.0,0.0],[0.0,0.0],[0.0,0.0],[1.0,0.0]]}}}]}}
```

See [noise model serialization](crate#noise-model-serialization) for more details.
