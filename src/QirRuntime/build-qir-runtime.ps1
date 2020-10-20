# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

# should replace ENABLE_NATIVE with ENABLE_QIRRUNTIME
if ($Env:ENABLE_NATIVE -ne "false") {
    Write-Host "##[info]Build QIR Runtime"
    $oldCC = $env:CC
    $oldCXX = $env:CC
    if (-not (Test-Path Env:AGENT_OS) -or ($Env:AGENT_OS.StartsWith("Win"))) {
        $env:CC = "C:\Program Files\LLVM\bin\clang.exe"
        $env:CXX = "C:\Program Files\LLVM\bin\clang++.exe"
        $llvmExtras = (Join-Path $PSScriptRoot "externals/LLVM")
        $env:PATH += ";$llvmExtras"
    } else {
        $env:CC = "/usr/bin/clang"
        $env:CXX = "/usr/bin/clang++"
    }
    $qirRuntimeBuildFolder = (Join-Path $PSScriptRoot "build")
    mkdir $qirRuntimeBuildFolder
    $qirRuntimeBuildFolder = (Join-Path $qirRuntimeBuildFolder $Env:BUILD_CONFIGURATION)
    mkdir $qirRuntimeBuildFolder
    pushd $qirRuntimeBuildFolder

    cmake -G Ninja -DCMAKE_BUILD_TYPE= $Env:BUILD_CONFIGURATION ../..
    cmake --build . --target install

    $env:CC = $oldCC
    $env:CXX = $oldCXX
    popd

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build QIR Runtime."
    }
} else {
    Write-Host "Skipping build of qir runtime because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}
