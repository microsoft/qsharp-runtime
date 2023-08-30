# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info] Simulation/Native/prerequisites.ps1"

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
    brew update
    brew install ninja
    brew install llvm@16
} elseif (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
    $ChocoRan = $false
    if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
        (Test-Path Env:/AGENT_OS)) {
        choco install llvm --version=16.0.6 --allow-downgrade
        $ChocoRan = $true
        Write-Host "##vso[task.setvariable variable=PATH;]$($env:SystemDrive)\Program Files\LLVM\bin;$Env:PATH"
    }
    if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
        choco install ninja
        $ChocoRan = $true
    }
    if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
        choco install cmake
        $ChocoRan = $true
    }
    if ($ChocoRan) {
        refreshenv
    }
}
else {
    $needClang = !(Get-Command clang-16 -ErrorAction SilentlyContinue)
    if (Get-Command sudo -ErrorAction SilentlyContinue) {
        if ($needClang) {
            wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|sudo apt-key add -
            sudo add-apt-repository "deb https://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main"
        }
        sudo apt update
        sudo apt-get install -y ninja-build
        sudo apt-get install -y libomp-16-dev
        sudo apt-get install -y clang-16
    } else {
        if ($needClang) {
            wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key|apt-key add -
            add-apt-repository "deb https://apt.llvm.org/jammy/ llvm-toolchain-jammy-16 main"
        }
        apt update
        apt-get install -y ninja-build
        apt-get install -y libomp-16-dev
        apt-get install -y clang-16
    }
}



