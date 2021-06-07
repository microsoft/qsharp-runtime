# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        if (!(Get-Command clang -ErrorAction SilentlyContinue)) {
            choco install llvm --version=11.1.0
        }
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            choco install ninja
        }
        if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
            choco install cmake
        }
    } elseif ($IsMacOS) {
        # temporary workaround for Bintray sunset
        # remove this after Homebrew is updated to 3.1.1 on MacOS image, see:
        # https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md
        brew update
        brew install ninja
    } else {
        sudo apt update
        sudo apt-get install -y ninja-build
        sudo apt-get install -y clang-11
        sudo apt-get install -y clang-tidy-11
    }
}

