# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        if (!(Get-Command clang -ErrorAction SilentlyContinue)) {
            choco install llvm
            choco install ninja
        }
    } elseif ($IsMacOS) {
        brew update
        brew install ninja
    } else {
        sudo apt update
        sudo apt-get install -y ninja-build
        sudo apt-get install -y clang-11
        sudo apt-get install -y clang-tidy-11
    }
}

