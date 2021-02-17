# The Native QIR Runtime

This folder contains QIR runtime project, which includes implementation of the
 [QIR specification](https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR) and the bridge to
 compile QIR to be run against the native full state simulator.

- `public` folder contains the public headers
- `lib` folder contains the implementation of the runtime and the simulators.
- `test` folder contains tests for the runtime
- `externals` folder contains external dependencies. We'll strive to keep those minimal.

## Build

The QirRuntime project is using CMake (3.17) + Ninja(1.10.0) + Clang++(10.0.0). Other versions of the tools might work
 but haven't been tested. Only x64 architecture is supported.

You can use CMake directly. For example, to produce a release build:

1. navigate into QirRuntime folder
2. mkdir build
3. cd build
4. cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
5. cmake --build .

Or you can run `build.py` script from QirRuntime folder. The default options for the script are `make debug`.

- (Windows) `python build.py [make/nomake] [debug|release] [noqirgen]`
- (Linux) `python3 build.py [make/nomake] [debug|release] [noqirgen]`

The script will place the build artifacts into `build/[Windows|Linux]/[Debug|Release]` folder. We strongly recommend
 doing local builds using the build script because it also runs clang-tidy.

CI builds and tests are enabled for this project. The build has no external dependencies, but some of the tests depend
 on `Microsoft.Quantum.Simulator.Runtime` library.

### Windows pre-reqs

1. Install Clang, Ninja and CMake from the public distros.
1. Add all three to your/system `%PATH%`.
1. Install VS 2019 and enable "Desktop development with C++" component (Clang uses MSVC's standard library on Windows).
1. Install clang-tidy and clang-format if your Clang/LLVM packages didn't include the tools.
1. Install the same version of dotnet as specified by qsharp-runtime [README](../../README.md)
1. <_optional_> To use build/test scripts install Python 3.8.

*Building from Visual Studio and VS Code is **not** supported.
Running cmake from the editors will likely default to MSVC or clang-cl and fail.*

### Linux via WSL pre-reqs

1. On the host Windows machine [enable WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and install
 Ubuntu 20.04 LTS.
1. In the Ubuntu's terminal:
    1. `$ sudo apt install cmake` (`$ cmake --version` should return 3.16.3)
    1. `$ sudo apt-get install ninja-build` (`$ ninja --version` should return 1.10.0)
    1. `$ sudo apt install clang` (`$ clang++ --version` should return 10.0.0)
    1. Set Clang as the preferred C/C++ compiler:
        - $ export CC=/usr/bin/clang
        - $ export CXX=/usr/bin/clang++
    1. `$ sudo apt install clang-tidy` (`$ clang-tidy --version` should return 'LLVM version 10.0.0')
    1. Install the same version of dotnet as specified by qsharp-runtime [README](../../README.md)
    1. <_optional_> To use build/test scripts, check that you have python3 installed (it should be by default).

See [https://code.visualstudio.com/docs/remote/wsl] on how to use VS Code with WSL.

## Test

Some of the tests depend on Microsoft.Quantum.Simulator.Runtime library. To run them make sure to build Native simulator
 from this repository or provide your own version of the library in a folder the OS would search during dynamic library
 lookup.

Some of the tests use generated QIR (*.ll) files as build input. Currently the files are checked-in as part of the project
 but in the future they will be replaced by automatic generation during build. To regenerate the files, run generateqir.py
 or build/test scripts without specifying `noqirgen`. To use the checked-in files without regenerating them, run build/test
 scripts with `noqirgen` argument.

### Running tests with test.py

To execute all tests locally run `test.py` from the project's root folder:

- (Windows) `python test.py [nobuild] [debug/release]`
- (Linux) `python3 test.py [nobuild] [debug/release]`

The script will trigger an incremental build unless `nobuild` options is specified. Tests from the "[skip]" category
 won't be run.

### Running tests with CTest

All native tests, including QIR, use catch2 and are fully integrated with CTest. Navigate into
 `build/[Windows|Linux]/[Debug|Release]` folder and run `ctest`. No configuration options required. The results will be
 logged into the corresponding `build/[Windows|Linux]/[Debug|Release]/<target_path>/<test_binary_name>_results.xml` file.
 Tests from the "[skip]" category won't be run.

### Running test binaries individually

`<test_binary> -help` provides details on how to run a subset of the tests and other options. For example, you can
 filter tests from the "[skip]" category out by `<test_binary> ~[skip]`.

For tests that depend on the native simulator and qdk shared libraries, you might need to modify the corresponding
 dynamic libraries lookup path environment variable:

- (Windows) PATH
- (Unix) LD_LIBRARY_PATH
- (Darwin) DYLD_LIBRARY_PATH

## QIR Bridge and Runtime

This project contains an implementation of the QIR runtime per the
 [QIR specifications](https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR) and the translation
 layer between the QIR and the IR, generated by Clang from the native code. Translation layer is called the "QIR Bridge".

![QIR Bridge architecture diagram](qir.png?raw=true "QIR Bridge architecture diagram")

This project also provides an implementation of the quantum instruction set, used by Q# for simulation against the full
state simulator:

```llvm
operation Exp (paulis : Pauli[], theta : Double, qubits : Qubit[]) : Unit is Adj + Ctl
void @__quantum__qis__exp__body(%Array*, double, %Array*)
void @__quantum__qis__exp__adj(%Array*, double, %Array*)
void @__quantum__qis__exp__ctl(%Array*, { %Array*, double, %Array* }*)
void @__quantum__qis__exp__ctladj(%Array*, { %Array*, double, %Array* }*)
void @__quantum__qis__h__body(%Qubit*)
void @__quantum__qis__h__ctl(%Array*, %Qubit*)
%Result* @__quantum__qis__measure__body(%Array*, %Array*)
void @__quantum__qis__r__body(i2, double, %Qubit*)
void @__quantum__qis__r__adj(i2, double, %Qubit*)
void @__quantum__qis__r__ctl(%Array*, { i2, double, %Qubit* }*)
void @__quantum__qis__r__ctladj(%Array*, { i2, double, %Qubit* }*)
void @__quantum__qis__s__body(%Qubit*)
void @__quantum__qis__s__adj(%Qubit*)
void @__quantum__qis__s__ctl(%Array*, %Qubit*)
void @__quantum__qis__s__ctladj(%Array*, %Qubit*)
void @__quantum__qis__t__body(%Qubit*)
void @__quantum__qis__t__adj(%Qubit*)
void @__quantum__qis__t__ctl(%Array*, %Qubit*)
void @__quantum__qis__t__ctladj(%Array*, %Qubit*)
void @__quantum__qis__x__body(%Qubit*)
void @__quantum__qis__x__ctl(%Array*, %Qubit*)
void @__quantum__qis__y__body(%Qubit*)
void @__quantum__qis__y__ctl(%Array*, %Qubit*)
void @__quantum__qis__z__body(%Qubit*)
void @__quantum__qis__z__ctl(%Array*, %Qubit*)
```

There are two ways to compile and run the QIR files against the runtime.

1. Link against the runtime libraries *statically*. For the example of this approach see `test/QIR-static` tests. It
 allows the client to access the target simulator directly, if so desired.
1. Link against the *shared qdk* library. The example of this approach can be found in `test/QIR-dynamic` folder. In the
 future we'll provide fully self-contained packages of the runtime to enable this workflow completely outside of the
 current project. For now, this way of consuming QIR only supports running against the native full state simulator.

QIR's architecture assumes a single target, whether that be hardware or a particular simulator. As a result, there is no
 provision in the QIR specifications to choose a target dynamically. To connect QIR to the simulators from this runtime,
 we provide `InitializeQirContext` and `ReleaseQirContext` methods. Switching contexts while executing QIR isn't
 supported and would yield undefined behavior.

### Building from IR files

CMake doesn't support using LLVM's IR files as input so instead we invoke Clang directly from custom commands to create
 utility libs that can be linked into other targets using their absolute paths.

*NB*: Compiling from IR has fewer checks than compiling from C++. For example, IR doesn't support overloading so
 declarations and definitions of functions are matched by name, without taking into account the arguments. This means
 that a build might succeed with mismatched signatures between caller/callee which will likely lead to crashes and other
 bugs at runtime.

**The QIR runtime is work in progress. Current known limitations are as follows:**

1. All functionality related to BigInt type (including `__quantum__rt__bigint_to_string`) NYI.
1. QIR is assumed to be __single threaded__. No effort was made to make the bridge and runtime thread safe.
1. Strings are implemented as a thin wrapper over std::string with virtually no optimizations.
1. Variadic functions (e.g. `__quantum__rt__array_create`) require platform specific bridges. The currently implemented
 bridge is for Windows.
1. Qubit borrowing NYI (needs both bridge and simulator's support).
1. `@ResultZero` and `@ResultOne` global variables, used in QIR generated from Q#, cannot be treated in a
 platform-agnostic way when linking against the shared qdk library.

## Coding style and conventions

Please enable file-based clang-format and run it before submitting your changes for review (in VS Code: Alt+Shift+F on
 a file). It will take care of spaces, indentations and many other formatting issues automatically and safely.

Most of our coding style and conventions are enforced via clang-tidy. The project is currently set up to treat
 clang-tidy warnings as build errors and we'd like to keep it this way. If you absolutely need to violate the style,
 mark the problematic line with `// NOLINT`. To suppress style checks in a whole folder, add .clang-tidy file into the
 folder with checks reduced to `Checks: '-*,bugprone-*'`.

Clang-tidy checks reference: [https://releases.llvm.org/10.0.0/tools/clang/tools/extra/docs/clang-tidy/checks/list.html]

Conventions not covered by .clang-format and .clang-tidy:

- fields of a class/struct must be placed at the top of the class/struct definition;
- must use `this` to access class and struct members: `this->fooBar`;
- Interface declarations should be placed in separate header files with "_I" suffix.: `FooBar_I.hpp`.
