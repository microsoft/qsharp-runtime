# The Native Quantum Runtime

This project contains headers for the native runtime, [possibly incomplete] implementations of a few
simulators, and the QIR-to-native bridge to support running QIR files against simulators from this or other native runtime(s).

- `public` folder contains the public headers
- `lib` folder contains the implementation of the runtime, the simulators and the QIR bridge
- `test` folder contains tests for the runtime
- `experimental` folder contains features for which specifications and design are in too early stage to include into the QDK.

## Build

The QirRuntime project is using CMake (3.17) + Ninja(1.10.0) + Clang++(10.0.0). Other versions of the tools might work but haven't been tested. Only x64 architecture is supported.

You can use CMake directly. For example, to produce a release build:

1. navigate into QirRuntime folder
2. mkdir build
3. cd build
4. cmake -G Ninja -DCMAKE_BUILD_TYPE=Release ..
5. cmake --build .

Or you can run `build.py` script from QirRuntime folder. The default options for the script are `make debug`.

- (Windows) `python build.py [make/nomake] [debug|release] [ir]`
- (Linux) `python3 build.py [make/nomake] [debug|release] [ir]`

The script will place the build artifacts into `build/[Windows|Linux]/[Debug|Release]` folder. We strongly recommend doing local builds using the build script because it also runs clang-tidy.

Note: OsX support will be added in the future.

### Windows pre-reqs

1. Install Clang, Ninja and CMake from the public distros.
2. Add all three to your/system `%PATH%`.
3. Install VS 2019 (Clang uses MSVC's standard library on Windows).
4. Install .NET Core 3.1
5. <_optional_> Either clone LLVM's repo and build LLVM locally to produce your own `opt.exe` and other IR tools or download LLVM's dev package.
6. Install clang-tidy and clang-format if your Clang/LLVM packages didn't include the tools.
7. <_optional_> To use build/test scripts install Python 3.8.

*Building from Visual Studio and VS Code is **not** supported.
Running cmake from the editors will likely default to MSVC or clang-cl and fail.*

### Linux via WSL pre-reqs

1. On the host Windows machine [enable WSL](https://docs.microsoft.com/en-us/windows/wsl/install-win10) and install Ubuntu 20.04 LTS.
2. In the Ubuntu's terminal:
    1. `$ sudo apt install cmake` (`$ cmake --version` should return 3.16.3)
    2. `$ sudo apt-get install ninja-build` (`$ ninja --version` should return 1.10.0)
    3. `$ sudo apt install clang` (`$ clang++ --version` should return 10.0.0)
    4. Set Clang as the preferred C/C++ compiler:
        - $ export CC=/usr/bin/clang
        - $ export CXX=/usr/bin/clang++
    5. `$ sudo apt install clang-tidy` (`$ clang-tidy --version` should return 'LLVM version 10.0.0')
    6. <_optional_> $ sudo apt install llvm
    7. <_optional_> To use build/test scripts, check that you have python3 installed (it should be by default).

See [https://code.visualstudio.com/docs/remote/wsl] on how to use VS Code with WSL.

### Generating IR

To generate IR of the native components as part of the build:

1. Install LLVM (see above) so you have opt.exe and other tools that work with IR.
2. Modify ProduceIR.cmake to point to these tools. (Or copy them into a separate folder and add that folder to `%PATH%.` If you are building LLVM locally, don't add the whole target build folder to `%PATH%` because it would likely confuse Clang.)
3. To produce IR once pass `ir` option to `build.py`. To do that on every build, uncomment setting `${GENERATE_IR}` variable in the root `CMakeLists.txt`.

## Test

To execute all tests locally, including QIR and managed interop (the interop is currently implemented for Windows only) run `test.py` from the project's root folder:

- (Windows) `python test.py [nobuild] [debug/release]`
- (Linux) `python3 test.py [nobuild] [debug/release]`

The script will trigger incremental build unless `nobuild` options is specified.

All test binaries and their dependencies are copied by the build into *install* folder: `build/[Windows|Linux]/[Debug|Release]/bin` and should be run from there (otherwise the tests might fail to load the shared libraries they depend on). On **Linux** `test.py` adds the install folder to LD_LIBRARY_PATH for the duration of the script. If you'd like to run the tests directly, add the path for the session manually. On WSL it might look like this: `$export LD_LIBRARY_PATH=/mnt/d/repos/qsharp-runtime/src/QirRuntime/build/Linux/Debug/bin:${LD_LIBRARY_PATH}`.

The project is using catch2 for all native tests, including QIR. `<test_binary> -help` provides details on how to run a subset of the tests and other options.

All native tests are fully integrated with CTest. The coverage is the same as when using `test.py` or running the test binaries individually, but CTest logs the results into the corresponding `build/[Windows|Linux]/[Debug|Release]/bin/<test_binary_name>_results.xml` file. To trigger tests this way, navigate into `build/[Windows|Linux]/[Debug|Release]` folder and run `ctest`. No configuration options required.

## QIR Bridge and Runtime

This project contains implementation of the QIR runtime per the specifications at [https://github.com/microsoft/qsharp-language/tree/main/Specifications/QIR] and the translation layer between the QIR and the IR, generated by Clang from the native code. We call the translation layer "QIR Bridge". This project also provides an optional implementation of intrinsics from `__quantum__qis*` namespace that are used in QIR, generated from Q#.

![QIR Bridge architecture diagram](qir.png?raw=true "QIR Bridge architecture diagram")

There are two ways to compile and run the QIR files against the runtime.

1. Link against the runtime libraries *statically*. For the example of this approach see `test/QIR-static` tests. It allows the client to access the target simulator directly, if so desired.
1. Link against the *shared qdk* library. The example of this approach can be found in `test/QIR-dynamic` folder. In the future we'll provide fully self-contained packages of the runtime to enable this workflow completely outside of the current project.

QIR's architecture assumes a single target, whether that be hardware or a particular simulator. As a result, there is no provision in the QIR specifications to choose a target dinamically. To connect QIR to the simulators from this runtime, we provide `SetCurrentQuantumApiForQIR(IQuantumApi*)` method. When linking against the shared qdk library, the method will be invoked automatically when creating an execution context. If linking statically, the client can call the method directly with the simulator of their choice. Switching simulators while executing QIR isn't supported, however, and would yield undefined behavior.

### Building from IR files
CMake doesn't support using LLVM's IR files as input so instead we invoke Clang directly from custom commands to create utility libs that can be linked into other targets using their absolute paths.

*NB*: Compiling from IR has fewer checks than compiling from C++. For example, IR doesn't support overloading so declarations
and definitions of functions are matched by name, without taking into account the arguments. This means that a build might
succeed with mismatched signatures between caller/callee which will likely lead to crashes and other bugs at runtime.

**The QIR runtime is work in progress. Current known limitations are as follows:**

1. All functionality related to BigInt type (including `__quantum__rt__bigint_to_string`) NYI.
2. QIR is assumed to be single threaded. No effort was made to make the bridge and runtime thread safe.
3. Strings are implemented as a thin wrapper over std::string with virtually no optimizations.
4. `__quantum__rt__string_create` currently doesn't conform to the spec (it expects a null terminated string rather than a string of specified length).
5. Variadic functions (e.g. `__quantum__rt__array_create`) require platform specific bridges. The currently implemented bridge is for Windows.
6. Qubit borrowing NYI (needs both bridge and simulator's support).
7. `@ResultZero` and `@ResultOne` global variables, used in QIR generated from Q#, cannot be treated in a platform-agnostic way when linking against the shared qdk library.

## Coding style and conventions

Please enable file-based clang-format and run it before submitting your changes for review (in VS Code: Alt+Shift+F on a file). It will take care of spaces, indentations and many other formatting issues
automatically and safely.

Most of our coding style and conventions are enforced via clang-tidy. The project is currently set up to treat clang-tidy warnings as build errors and we'd like to keep it this way. If you absolutely need to violate the style, mark the problematic line with `// NOLINT`. To suppress style checks in a whole folder, add .clang-tidy file into the folder with checks reduced to `Checks: '-*,bugprone-*'`.

Clang-tidy checks reference: [https://releases.llvm.org/10.0.0/tools/clang/tools/extra/docs/clang-tidy/checks/list.html]

Conventions not covered by .clang-format and .clang-tidy:

- fields of a class/struct must be placed at the top of the class/struct definition;
- must use `this` to access class and struct members: `this->fooBar`;
- early returns from guard checks at the beginning of a function are allowed, early returns in all other cases are discouraged;
- should have one interface declaration per header and prefix the file name with 'I': `IFooBar.hpp`.
