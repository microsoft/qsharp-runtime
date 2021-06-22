# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

if ($Env:ENABLE_NATIVE -ne "false") {
    $nativeSimulator = (Join-Path $PSScriptRoot "../src/Simulation/Native")
    & "$nativeSimulator/test-native-simulator.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping test of native simulator because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}
function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    if ("" -ne "$Env:ASSEMBLY_CONSTANTS") {
        $args = @("/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS");
    }  else {
        $args = @();
    }
    dotnet test $(Join-Path $PSScriptRoot $project) `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --logger trx `
        @args `
        /property:Version=$Env:ASSEMBLY_VERSION

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to test $project"
        $script:all_ok = $False
    }
}

Test-One '../Simulation.sln'

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    $qirRuntime = (Join-Path $PSScriptRoot "../src/Qir/Runtime")
    & "$qirRuntime/test-qir-runtime.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }

    $qirTests = (Join-Path $PSScriptRoot "../src/Qir/Tests")
    & "$qirTests/test-qir-tests.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }

    $qirSamples = (Join-Path $PSScriptRoot "../src/Qir/Samples")
    & "$qirSamples/test-qir-samples.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }

    $qirController = (Join-Path $PSScriptRoot "../src/Qir/Controller")
    & "$qirController/test-qir-controller.ps1"

    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping test of qir runtime because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME."
}


if ($Env:ENABLE_EXPERIMENTALSIM -ne "false") {
    if (-not (Get-Command cargo -ErrorAction SilentlyContinue)) {
        # Cargo was missing, so cannot test experimental simulators.
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
        $expSim = (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
        & "$expSim/test-qdk-sim-rs.ps1"
        if ($LastExitCode -ne 0) {
            $script:all_ok = $False
        }
    }
} else {
    Write-Host "Skipping test of experimental simulators because ENABLE_OPENSIM variable is set to: $Env:ENABLE_OPENSIM."
}

if (-not $all_ok) {
    throw "At least one project failed during testing. Check the logs."
}
