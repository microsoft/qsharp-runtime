# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

if ($Env:ENABLE_NATIVE -ne "false") {
    $nativeSimulator = (Join-Path $PSScriptRoot "../src/Simulation/Native")
    & "$nativeSimulator/build-native-simulator.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of native simulator because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
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
        /property:QSharpDocsOutputPath=$Env:DOCS_OUTDIR;

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to build $project."
        $script:all_ok = $False
    }
}

Build-One 'publish' '../src/Simulation/CSharpGeneration.App'

Build-One 'build' '../Simulation.sln'

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    $qirRuntime = (Join-Path $PSScriptRoot "../src/QirRuntime")
    & "$qirRuntime/build-qir-runtime.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of qir runtime because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME"
}

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}
