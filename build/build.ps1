# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

if ($Env:ENABLE_NATIVE -ne "false") {
    Write-Host "##[info]Build Native simulator"
    $nativeBuild = (Join-Path $PSScriptRoot "../src/Simulation/Native/build")
    cmake --build $nativeBuild --config $Env:BUILD_CONFIGURATION
    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
        $script:all_ok = $False
    }

    Write-Host "##[info]Build QIR Runtime"
    $oldCC = $env:CC
    $oldCXX = $env:CC
    if (-not (Test-Path Env:AGENT_OS) -or ($Env:AGENT_OS.StartsWith("Win"))) {
        $env:CC = "C:\Program Files\LLVM\bin\clang.exe"
        $env:CXX = "C:\Program Files\LLVM\bin\clang++.exe"
    } else {
        $env:CC = "/usr/bin/clang"
        $env:CXX = "/usr/bin/clang++"
    }
    Write-Host $Env:AGENT_OS
    $qirRuntimeBuildFolder = (Join-Path $PSScriptRoot "../src/QirRuntime/build")
    mkdir $qirRuntimeBuildFolder
    $qirRuntimeBuildFolder = (Join-Path $qirRuntimeBuildFolder $Env:BUILD_CONFIGURATION)
    mkdir $qirRuntimeBuildFolder
    pushd $qirRuntimeBuildFolder

    cmake -G Ninja -DCMAKE_BUILD_TYPE= $Env:BUILD_CONFIGURATION ../..
    cmake --build .

    $env:CC = $oldCC
    $env:CXX = $oldCXX
    popd

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build QIR Runtime."
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping native because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}

function Build-One {
    param(
        [string]$action,
        [string]$project
    );

    Write-Host "##[info]Building $project ($action)..."
    if ("" -ne "$Env:ASSEMBLY_CONSTANTS") {
        $args = @("/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS");
    }  else {
        $args = @();
    }
    dotnet $action $(Join-Path $PSScriptRoot $project) `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY  `
        @args `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QsharpDocsOutputPath=$Env:DOCS_OUTDIR;

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $project."
        $script:all_ok = $False
    }
}

Build-One 'publish' '../src/Simulation/CsharpGeneration.App'

Build-One 'build' '../Simulation.sln'

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}
