# Code Quality for New C/C++ Projects

This section provides the instructions and examples for improving/preserving the code quality for new C/C++ projects.

## Compiler Warnings

(Code Correctness)  
The compiler warnings help developers detect the current and future issues in the code.
It is recommended to treat the warnings as errors,
otherwise some of the warnings will stay unnoticed and the number of such warnings will grow.
The example of the warnings and links to the documentation can be found by searching for "warningFlags" in
[Qir/qir-utils.ps1](Qir/qir-utils.ps1).

## Clang-Tidy

(Code Correctness/Static Analysis, Code Style)  
Clang-tidy is a tool that can improve the code correctness by using the static analysis. It can also enforce some
aspects of the code style.

* Documentation
  * [Clang-tidy](https://clang.llvm.org/extra/clang-tidy/)
  * [Clang-Tidy Checks](https://clang.llvm.org/extra/clang-tidy/checks/list.html)
* Example of the checks used
  * [Qir/.clang-tidy](Qir/.clang-tidy)
  * [Qir/Tests/.clang-tidy](Qir/Tests/.clang-tidy)
  * [Qir/Samples/StandaloneInputReference/.clang-tidy](Qir/Samples/StandaloneInputReference/.clang-tidy)
* Use
  * Install: On Win and Mac is installed together with LLVM or Clang, to install on Linux search for "tidy" in
    [Qir/Runtime/prerequisites.ps1](Qir/Runtime/prerequisites.ps1).
  * Run: Search for "tidy" in [Qir/qir-utils.ps1](Qir/qir-utils.ps1)

## Clang Sanitizers

(Code Correctness/Dynamic Analysis)  
Clang Sanitizers are a family of the dynamic analysis tools.

They slow down the code, that is why in QIR Runtime they
are enabled in Debug configuration only. And there is a special pipeline that builds the Debug configuration and runs
the tests and examples against it.

* Documentation
  * [Controlling Code Generation](https://clang.llvm.org/docs/UsersManual.html#controlling-code-generation)
* Example: Search for "sanitize" in [Qir/qir-utils.ps1](Qir/qir-utils.ps1).
* Pipeline
  * Files: Search for the files whose name contains "-codecheck.yml" in [/build](../build) directory.
  * microsoft.qsharp-runtime.sanitized - the CI pipeline itself (Microsoft internal resource).

## Clang-Format

(Code Style)  
Clang-format is a tool that enforces the code style.

* Links to the documentation, example of the options are in [Qir/.clang-format](Qir/.clang-format).
* Installation: Search for "format" in [Qir/Runtime/prerequisites.ps1](Qir/Runtime/prerequisites.ps1).
* Run: [Qir/check-sources-formatted.ps1](Qir/check-sources-formatted.ps1).

## See also

* [Coding style and conventions](Qir/Runtime/README.md#coding-style-and-conventions)