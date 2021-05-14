# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Push-Location (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
    # We use dotnet-script to inject the version number into Cargo.toml,
    # so we go on ahead here and restore any missing tools.
    # Since that Cargo.toml is referenced by CMake lists in the QIR
    # runtime, this injection has to be the first thing we do.
    dotnet tool restore
    dotnet script inject-version.csx -- `
        --template Cargo.toml.template `
        --out-path Cargo.toml `
        --version $Env:NUGET_VERSION;
Pop-Location

if ($Env:ENABLE_NATIVE -ne "false") {
    $nativeSimulator = (Join-Path $PSScriptRoot "../src/Simulation/Native")
    & "$nativeSimulator/build-native-simulator.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of native simulator because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    $qirRuntime = (Join-Path $PSScriptRoot "../src/Qir/Runtime")
    & "$qirRuntime/build-qir-runtime.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of qir runtime because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME"
}

if ($Env:ENABLE_EXPERIMENTALSIM -ne "false") {
    $expSim = (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
    & "$expSim/build-qdk-sim-rs.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of experimental simulators because ENABLE_OPENSIM variable is set to: $Env:ENABLE_OPENSIM."
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
    $qirTests = (Join-Path $PSScriptRoot "../src/Qir/Tests")
    & "$qirTests/build-qir-tests.ps1" -SkipQSharpBuild
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
    $qirSamples = (Join-Path $PSScriptRoot "../src/Qir/Samples")
    & "$qirSamples/build-qir-samples.ps1" -SkipQSharpBuild
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping build of qir tests because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME"
}

if (-not $all_ok) {
    throw "At least one project failed to compile. Check the logs."
}
