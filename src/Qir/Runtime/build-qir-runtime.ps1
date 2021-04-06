# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

 param (
    [bool]$buildAll = $true
 )

& (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)

function Build-QirProject {
    param (
        [string]
        $FolderPath
    )

    if ($buildAll -Or !(Test-Path (Join-Path $FolderPath qir *.ll))) {
        Write-Host "##[info]Build Q# project for QIR tests '$FolderPath'"
        dotnet build $FolderPath -c $Env:BUILD_CONFIGURATION -v $Env:BUILD_VERBOSITY
        if ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to compile Q# project at '$FolderPath' into QIR."
            throw "Failed to compile Q# project at '$FolderPath' into QIR."
        }
    }
    Copy-Item -Path (Join-Path $FolderPath qir *.ll) -Destination (Split-Path $FolderPath -Parent)
    # Also copy to drops so it ends up in build artifacts, for easier post-build debugging.
    Copy-Item -Path (Join-Path $FolderPath qir *.ll) -Destination $Env:DROPS_DIR
}

Write-Host "##[info]Compile Q# Projects into QIR"
Build-QirProject (Join-Path $PSScriptRoot test QIR-static qsharp)
Build-QirProject (Join-Path $PSScriptRoot test QIR-dynamic qsharp)
Build-QirProject (Join-Path $PSScriptRoot test QIR-tracer qsharp)
Build-QirProject (Join-Path $PSScriptRoot test FullstateSimulator qsharp)
Build-QirProject (Join-Path $PSScriptRoot samples StandaloneInputReference qsharp)


Write-Host "##[info]Build QIR Runtime"
$oldCC = $env:CC
$oldCXX = $env:CXX
$oldRC = $env:RC

$clangTidy = ""

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    Write-Host "On MacOS build QIR Runtime using the default C/C++ compiler (should be AppleClang)"
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build QIR Runtime using Clang"
    $env:CC = "clang-11"
    $env:CXX = "clang++-11"
    $env:RC = "clang++-11"
    $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy-11"
}
elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    Write-Host "On Windows build QIR Runtime using Clang"
    $env:CC = "clang.exe"
    $env:CXX = "clang++.exe"
    $env:RC = "clang++.exe"

    if (!(Get-Command clang -ErrorAction SilentlyContinue) -and (choco find --idonly -l llvm) -contains "llvm") {
        # LLVM was installed by Chocolatey, so add the install location to the path.
        $env:PATH += ";$($env:SystemDrive)\Program Files\LLVM\bin"
    }

    if (Get-Command clang-tidy -ErrorAction SilentlyContinue) {
        # Only run clang-tidy if it's installed. This is because the package used by chocolatey on
        # the build pipeline doesn't include clang-tidy, so we allow skipping that there and let
        # the Linux build catch tidy issues.
        $clangTidy = "-DCMAKE_CXX_CLANG_TIDY=clang-tidy"
    }
} else {
    Write-Host "##vso[task.logissue type=error;]Failed to identify the OS. Will use default CXX compiler"
}

$qirRuntimeBuildFolder = (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION)
if (-not (Test-Path $qirRuntimeBuildFolder)) {
    New-Item -Path $qirRuntimeBuildFolder -ItemType "directory"
}

$all_ok = $true

Push-Location $qirRuntimeBuildFolder

cmake -G Ninja $clangTidy -D CMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ../..
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to generate QIR Runtime."
    $all_ok = $false
} else {
    cmake --build . --target install
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build QIR Runtime."
        $all_ok = $false
    }
}

$os = "win"
$pattern = @("*.dll", "*.lib")
if ($IsMacOS) {
    $os = "osx"
    $pattern = @("*.dylib")
} elseif ($IsLinux) {
    $os = "linux"
    $pattern = @("*.so")
}
$osQirDropFolder = Join-Path $Env:DROPS_DIR QIR $os
if (!(Test-Path $osQirDropFolder)) {
    New-Item -Path $osQirDropFolder -ItemType "directory"
}
$pattern | Foreach-Object { Copy-Item (Join-Path . bin $_) $osQirDropFolder -ErrorAction SilentlyContinue }
Copy-Item (Join-Path $env:NATIVE_SIMULATOR "Microsoft.Quantum.Simulator.Runtime.dll") $osQirDropFolder -ErrorAction SilentlyContinue
$env:PATH += ";" + $osQirDropFolder

Pop-Location

$env:CC = $oldCC
$env:CXX = $oldCXX
$env:RC = $oldRC

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}
