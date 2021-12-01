# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
    # # building with gcc-9 succeeds but some of the unit tests fail
    # Write-Host "Install gcc-7 as pre-req for building native simulator on MacOS"
    # # temporary workaround for Bintray sunset
    # # remove this after Homebrew is updated to 3.1.1 on MacOS image, see:
    # # https://github.com/actions/virtual-environments/blob/main/images/macos/macos-10.15-Readme.md
    # brew update
    # brew install gcc@7
    brew install libomp
} elseif (($IsWindows) -or ((Test-Path Env:/AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
    if (!(Get-Command clang        -ErrorAction SilentlyContinue) -or `
        (Test-Path Env:/AGENT_OS)) {
        choco install llvm --version=11.1.0 --allow-downgrade
        Write-Host "##vso[task.setvariable variable=PATH;]$($env:SystemDrive)\Program Files\LLVM\bin;$Env:PATH"
    }
    if (!(Get-Command ninja -ErrorAction SilentlyContinue)) {
        choco install ninja
    }
    if (!(Get-Command cmake -ErrorAction SilentlyContinue)) {
        choco install cmake
    }
    refreshenv
}
else {
    # Write-Host "No pre-reqs for building native simulator on platforms other than MacOS"
    if (Get-Command sudo -ErrorAction SilentlyContinue) {
        sudo apt update
        sudo apt-get install -y clang-11
    } else {
        apt update
        apt-get install -y clang-11
    }
}



