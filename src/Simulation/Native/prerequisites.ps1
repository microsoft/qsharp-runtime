# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info] Simulation/Native/prerequisites.ps1"

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
    brew update
    if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
        Write-Output "Installing ninja"
        brew install ninja
    }
    if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
        Write-Output "Installing ccache"
        brew install ccache
    }
    brew install llvm@14
} elseif (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
    if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
        (Test-Path Env:/AGENT_OS)) {
        choco install llvm --version=14.0.6 --allow-downgrade
        Write-Host "##vso[task.setvariable variable=PATH;]$($env:SystemDrive)\Program Files\LLVM\bin;$Env:PATH"
    }
    if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
        Write-Output "Installing ninja"
        choco install --accept-license -y ninja
    }
    if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
        Write-Output "Installing cmake"
        choco install --accept-license -y cmake
    }
    if (!(Get-Command sccache -ErrorAction SilentlyContinue)) {
        Write-Output "Installing sccache"
        choco install --accept-license -y sccache
    }
    refreshenv
}
else {
    $needClang = !(Get-Command clang-14 -ErrorAction SilentlyContinue)
    if (Get-Command sudo -ErrorAction SilentlyContinue) {
        if ($needClang) {
            wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
            sudo add-apt-repository "deb https://apt.llvm.org/focal/ llvm-toolchain-focal-14 main"
        }
        sudo apt update
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            Write-Output "Installing ninja-build"
            sudo apt-get install -y --no-install-recommends ninja-build
        }
        if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
            Write-Output "Installing ccache"
            sudo apt-get install -y --no-install-recommends ccache
        }
        sudo apt-get install -y --no-install-recommends libomp-14-dev
        sudo apt-get install -y --no-install-recommends clang-14
    } else {
        if ($needClang) {
            wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
            add-apt-repository "deb https://apt.llvm.org/focal/ llvm-toolchain-focal-14 main"
        }
        apt update
        if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
            Write-Output "Installing ninja-build"
            apt-get install -y --no-install-recommends ninja-build
        }
        if (!(Get-Command ccache -ErrorAction SilentlyContinue)) {
            Write-Output "Installing ccache"
            apt-get install -y --no-install-recommends ccache
        }
        apt-get install -y --no-install-recommends libomp-14-dev
        apt-get install -y --no-install-recommends clang-14
    }
}



