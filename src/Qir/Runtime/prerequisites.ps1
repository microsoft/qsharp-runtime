# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#Requires -Version 6.0

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    if (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
            !(Get-Command clang-format -ErrorAction SilentlyContinue)) {
            choco install llvm --version=11.1.0
            Write-Host "##vso[task.setvariable variable=PATH;]$Env:Path;C:\Program Files\LLVM\bin"
        }
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            choco install ninja
        }
        if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
            choco install cmake
        }
        refreshenv
    } elseif ($IsMacOS) {
        # temporary workaround for Bintray sunset
        # remove this after Homebrew is updated to 3.1.1 on MacOS image, see:
        # https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md
        brew update
        brew install ninja
        if (!(Get-Command clang-format -ErrorAction SilentlyContinue)) {
            brew install clang-format
        }
    } else {
        if (Get-Command sudo -ErrorAction SilentlyContinue) {
            sudo apt update
            sudo apt-get install -y ninja-build clang-11 clang-tidy-11 clang-format-11
        } else {
            apt update
            apt-get install -y ninja-build clang-11 clang-tidy-11 clang-format-11
        }
    }
}

