# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

#Requires -Version 6.0

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    if (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
            !(Get-Command clang-format -ErrorAction SilentlyContinue) -or `
            (Test-Path Env:/AGENT_OS)) {
            choco install llvm --version=13.0.0 --allow-downgrade
            Write-Host "##vso[task.setvariable variable=PATH;]$($env:SystemDrive)\Program Files\LLVM\bin;$Env:PATH"
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
        $needClang = (Get-Command clang-13 -ErrorAction SilentlyContinue)
        if (Get-Command sudo -ErrorAction SilentlyContinue) {
            if ($needClang) { 
                wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
                sudo add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-13 main"
            }
            sudo apt update
            sudo apt-get install -y ninja-build clang-13 clang-tidy-13 clang-format-13
        } else {
            if ($needClang) {
                wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
                add-apt-repository "deb http://apt.llvm.org/focal/ llvm-toolchain-focal-13 main"
            }
            apt update
            apt-get install -y ninja-build clang-13 clang-tidy-13 clang-format-13
        }
    }
}

