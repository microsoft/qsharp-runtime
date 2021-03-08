# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& (Join-Path $PSScriptRoot .. .. build set-env.ps1)
Write-Host "##[info]Compile Q# Projects into QIR"
$qirStaticPath = Join-Path $PSScriptRoot test QIR-static qsharp
dotnet build $qirStaticPath -c $Env:BUILD_CONFIGURATION -v $Env:BUILD_VERBOSITY
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to compile Q# project at '$qirStaticPath' into QIR."
    return
}
Copy-Item -Path (Join-Path $qirStaticPath qir *.ll) -Destination (Split-Path $qirStaticPath -Parent)
# Also copy to drops so it ends up in build artifacts, for easier post-build debugging.
Copy-Item -Path (Join-Path $qirStaticPath qir *.ll) -Destination $Env:DROPS_DIR

Write-Host "##[info]Build QIR Runtime"
$oldCC = $env:CC
$oldCXX = $env:CXX
$oldRC = $env:RC

$clangTidy = ""

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    Write-Host "On MacOS build QIR Runtim using the default C/C++ compiler (should be AppleClang)"
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build QIR Runtime using Clang"
    $env:CC = "/usr/bin/clang-11"
    $env:CXX = "/usr/bin/clang++-11"
    $env:RC = "/usr/bin/clang++-11"
    $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy-11"
}
elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    Write-Host "On Windows build QIR Runtime using Clang"
    $env:CC = "C:\Program Files\LLVM\bin\clang.exe"
    $env:CXX = "C:\Program Files\LLVM\bin\clang++.exe"
    $env:RC = "C:\Program Files\LLVM\bin\clang++.exe"
    $llvmExtras = (Join-Path $PSScriptRoot "externals/LLVM")
    $env:PATH += ";$llvmExtras"

    if (Get-Command clang-tidy -ErrorAction SilentlyContinue) {
        $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy"
    }
} else {
    Write-Host "##vso[task.logissue type=error;]Failed to identify the OS. Will use default CXX compiler"
}

$qirRuntimeBuildFolder = (Join-Path $PSScriptRoot "build\$Env:BUILD_CONFIGURATION")
if (-not (Test-Path $qirRuntimeBuildFolder)) {
    New-Item -Path $qirRuntimeBuildFolder -ItemType "directory"
}

Push-Location $qirRuntimeBuildFolder

cmake -G Ninja $clangTidy -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ../..
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to generate QIR Runtime."
}
cmake --build . --target install
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build QIR Runtime."
}

$os = "win32"
$pattern = "*.dll"
if ($IsMacOS) {
    $os = "osx"
    $pattern = "*.dylib"
} elseif ($IsLinux) {
    $os = "linux"
    $pattern = "*.so"
}
$osQirDropFolder = Join-Path $Env:DROPS_DIR QIR $os
if (!(Test-Path $osQirDropFolder)) {
    New-Item -Path $osQirDropFolder -ItemType "directory"
}
Copy-Item (Join-Path . bin $pattern) $osQirDropFolder

Pop-Location

$env:CC = $oldCC
$env:CXX = $oldCXX
$env:RC = $oldRC
