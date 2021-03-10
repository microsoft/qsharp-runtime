# External components

## LLVM tools

We are relying on llvm-ar.exe 10.0.0 when building directly from IR. The tool is part of the official LLVM release package and can be installed from https://releases.llvm.org. However, it's not included into the Chocolatey package we are using to deply LLVM on Windows cloud build machines.

While we are looking into a proper solution for this dependency, we are providing the tools as part of the repository.

## Catch2

We are using v2.12.1 single-header distribution of catch2 native framework from https://github.com/catchorg/Catch2 (2e61d38c7c3078e600c331257b5bebfb81aaa685).

## CLI11

We are using v1.9.1 single-header distribution of CLI11 command line parser for C++ from (https://github.com/CLIUtils/CLI11) (5cb3efabce007c3a0230e4cc2e27da491c646b6c).
