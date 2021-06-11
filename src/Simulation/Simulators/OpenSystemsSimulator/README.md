# .NET Bindings for Quantum Development Kit Experimental Simulators

The .NET classes defined in this folder utilize the C library built from the `qdk_sim` Rust crate to provide bindings to the experimental simulators that can be used from Q# programs.

<!-- TODO: Replace this paragraph with the docs.rs link once the crate is live. -->
For more details on the `qdk_sim` crate, and its APIs for Rust, C, and Python, please see the documentation provided with that crate. From the root of this repository:

```bash
pwsh ./bootstrap.ps1
cd src/Simulation/qdk_sim_rs
cargo +nightly doc --features python --open
```

For more details on using these simulators from Q# programs called from Python hosts, please see <https://github.com/microsoft/iqsharp>.

## Known limitations

As this feature is currently under development, there are still a number of limitations and missing capabilities.

- Continuous-time rotations (e.g.: `Rx`, `Ry`, `Rz`, and `Exp`) are not yet supported.
- Fractional rotations (e.g.: `R1Frac`, `ExpFrac`) are not yet supported.
- The `Controlled Y` operation with more than one control qubit is not yet supported.
- The `Controlled T` operation is not yet supported.
- Joint measurement is not yet supported.

Some limitations are inherent to open systems simulation, and may not ever be supported:

- Assertions (e.g.: `AssertMeasurement` and `AssertMeasurementProbability`) are not supported, as these assertions may fail for correct code in the presence of noise. These assertions are no-ops on the experimental simulators.

## Native interface

The core interoperability boundary between the C# runtime for the Quantum Development Kit and the `qdk_sim` native library is defined in the [`NativeInterface` static class](./NativeInterface.cs). This class provides P/Invoke declarations for each function exposed by the C API for the `qdk_sim` crate, as well as methods that call into these C API methods. The managed methods that correspond to each C API function check error codes reuturned by C API functions and convert them into .NET exceptions, allowing for C API errors to be easily caught by managed code.

For example, to use the native API to create a new simulator with a mixed-state representation:

```csharp
using static Microsoft.Quantum.Experimental.NativeInterface;

var simId = Init(initialCapacity: 3, representation: "mixed");
try
{
    H(simId, 0);
    var result = M(simId, 0);
    System.Console.Out.WriteLine($"Got {result}!");
}
finally
{
    Destroy(simId);
}
```

## Q# simulator interface

For most applications, the native interface is not useful on its own, but as called as a Q# simulator. The [`OpenSystemsSimulator` class](./OpenSystemsSimulator.cs) provides bindings between the native interface described above and the `SimulatorBase` class in the C# runtime for Q#.

This class implements each of the intrinsic Q# operations either directly as a call into the `qdk_sim` library, or by using [decompositions](./Decompositions) to reduce Q# intrinsics into those intrinsics supported by the experimental simulators.

To create a new simulator, use the constructor for the `OpenSystemsSimulator` class:

```csharp
var qsim = new OpenSystemsSimulator(3, "mixed");
```

The noise model for the simulator can be accessed or set using the `OpenSystemsSimulator.NoiseModel` property (see [noise modeling API](#noise-modeling-api), below)):

```csharp
qsim.NoiseModel =
    NoiseModel.TryGetByName("ideal_stabilizer", out var noiseModel)
    ? noiseModel
    : throw new Exception("Noise model with name 'ideal_stabilizer' not found.");
```

This simulator can then be used as any other Q# simulator.

## Noise modeling API

To get and set noise models, each of the data structures in the `qdk_sim` crate has an analogous C# class that can be used to serialize and deserialize `qdk_sim` data structures as JSON objects.

In particular, the [`NoiseModel` class](./DataModel/NoiseModel.cs) class parallels the `NoiseModel` struct in the `qdk_sim` crate, and allows accessing or modifying the noise model used by experimental simulators to run each Q# program.
