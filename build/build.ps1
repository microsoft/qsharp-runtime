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
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        # Cargo was missing, so cannot build experimental simulators.
        # That's fine if running locally, we'll warn the user and then skip.
        # On CI, though, we should fail when the experimental simulator build
        # is turned on by ENABLE_EXPERIMENTALSIM, but we can't actually
        # proceed.
        if ("$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true") {
            Write-Host "##[error]Experimental simulators enabled, but cargo was not installed in CI pipeline.";
        } else {
            Write-Warning `
                "Experimental simulators enabled, but cargo missing. " + `
                "Either install cargo, or set `$Env:ENABLE_EXPERIMENTALSIM " + `
                "to `"false`". Skipping experimental simulators.";
        }
    } else {
        # Prerequisites are met, so let's go.
        $expSim = (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
        & "$expSim/build-qdk-sim-rs.ps1"
        if ($LastExitCode -ne 0) {
            $script:all_ok = $False
        }
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
