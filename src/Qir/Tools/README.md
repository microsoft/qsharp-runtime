# Microsoft.Quantum.Qir.Runtime.Tools

QIR executables are built by generating a C++ driver that is compiled and linked with the compiled QIR bitcode.

## Driver

This folder contains the implementation for the C++ driver generation.

The C++ driver provides an entry-point for executing a QIR program. It handles parsing of command line arguments, and it invokes an entry-point function exposed by the QIR program.

C++ is generated using [Visual Studio T4 text templates](https://docs.microsoft.com/en-us/visualstudio/modeling/code-generation-and-t4-text-templates?view=vs-2019). *\*.tt* files represent the text templates. When the Microsoft.Quantum.Qir.Runtime.Tools project is built using Visual Studio, a *\*.cs* (C\#) file is generated per each *\*.tt* file. The generated *\*.cs* file implements a class named as the template filename that provides a `TransformText` method used to generate the final text.

**Note**: Generated *\*.cs* files are included in source control because T4 text templates are not cross-platform and cannot be generated during build pipelines.

## Executable

This folder contains the implementation for building and running QIR executables.

## Externals

This folder contains third-party components used to build and run QIR executables.

## Utility

This folder contains utility general-purpose classes used across the Microsoft.Quantum.Qir.Runtime.Tools project.
