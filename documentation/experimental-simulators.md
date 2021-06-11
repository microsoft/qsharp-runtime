# Using the Experimental Simulators for the Quantum Development Kit

As an experimental feature, the Quantum Development Kit provides capabilities for noisy and stabilizer simulation. This feature allows for simulating the behavior of Q# programs under the influence of noise, and for using the stabilizer representation (a.k.a. CHP simulation) with programs that only call Clifford operations.

> For more information about the development of this feature, please see the GitHub issue at <https://github.com/microsoft/qsharp-runtime/issues/714>.

Currently, the experimental simulators are supported for use with:

- C# host programs
- Python host programs
- Q# standalone notebooks

The experimental simulators are not yet supported by:

- Q# standalone command-line programs
- QIR-based executables

## Known limitations

As this feature is currently under development, there are still a number of limitations and missing capabilities.

- Continuous-time rotations (e.g.: `Rx`, `Ry`, `Rz`, and `Exp`) are not yet supported.
- Fractional rotations (e.g.: `R1Frac`, `ExpFrac`) are not yet supported.
- The `Controlled Y` operation with more than one control qubit is not yet supported.
- The `Controlled T` operation is not yet supported.
- Joint measurement is not yet supported.

Some limitations are inherent to open systems simulation, and may not ever be supported:

- Assertions (e.g.: `AssertMeasurement` and `AssertMeasurementProbability`) are not supported, as these assertions may fail for correct code in the presence of noise. These assertions are no-ops on the experimental simulators.

## Using Experimental Simulators from Python

> ### **ⓘ** TIP
>
> See the [example on using the experimental simulators from Python](./examples/experimental-simulators-from-python.ipynb) for more details.

Once you have the right version of the `qsharp-core` Python package installed, you can enable the use of the experimental simulators by using the `qsharp.experimental` module:

```python
import qsharp
import qsharp.experimental
qsharp.experimental.enable_noisy_simulation()
```

After calling `enable_noisy_simulation()`, Q# operations imported into Python will expose a `.simulate_noise()` method that can be used to run Q# programs against the experimental simulators.

By default, `.simulate_noise()` will assume an ideal error model (that is, no noise). To configure a particular error model, use the `qsharp.experimental.get_noise_model` and `qsharp.experimental.set_noise_model` functions to get and set the current noise model for the experimental simulators. Each error model is represented as a dictionary from intrinsic operation names to objects representing the errors in those intrinsic operations.

For open systems simulation, error channels can be represented by [QuTiP](https://qutip.org/) `Qobj` objects encoding superoperators.
