# External components

## LLVM tools

We are relying on llvm-ar.exe when building directly from IR. The tool is part of the official LLVM release package and can be installed from https://github.com/llvm/llvm-project/releases/download. However, it's not included into the Chocolatey package we are using to deply LLVM on Windows cloud build machines.

While we are looking into a proper solution for this dependency, we are providing the tools as part of the repository.

## Catch2

We are using v2.12.1 single-header distribution of catch2 native framework from https://github.com/catchorg/Catch2 (2e61d38c7c3078e600c331257b5bebfb81aaa685).
