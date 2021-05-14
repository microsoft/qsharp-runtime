## Code quality checks

The build for this crate enforces the following mandatory code quality checks:

- `rustfmt`: Check code style and formatting rules.
- `clippy`: Check for common programming errors and linter violations.
- `#[deny(missing_docs)]`: Require API documentation for all public crates, modules, traits, functions, and types.

## Testing strategy

Tests for the open systems simulator consist of five distinct parts:

- Rust-language unit tests for the Rust library.
  These tests are defined in `#[cfg(test)]` submodules of each module in `./src/`.
- Rust-language integration tests for the Rust library.
  These tests are defined in modules under the `./tests/` folder.
- C++-language unit tests in the QIR runtime.
  These tests ensure that the binding of the Rust library as a QIR simulator work as expected, and are defined in `qsharp-runtime/src/QirRuntime/test/OpenSystemsSimulator/*.cpp`.
- Q#-language unit tests in the C#-based simulation runtime.
  These tests ensure that the binding of the Rust library works as expected when included into the C#-based runtime, and are defined in operations marked with `@Test("Microsoft.Quantum.Experimental.OpenSystemsSimulator")` under the `qsharp-runtime/src/Simulation/Simulators.Tests/QuantumTestSuite` folder.
- C#-language unit tests in the IQ# kernel.
  These tests ensure that noise models and noisy simulation can be correctly exposed to Python and Q# notebook users; please see the `microsoft/iqsharp` repo for more details.
