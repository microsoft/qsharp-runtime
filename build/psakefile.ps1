# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

$ErrorActionPreference = 'Stop'

include (Join-Path $PSScriptRoot "set-env.ps1")

task default -depends set-env, qir-runtime, native-simulation, experimental-simulator, simulator-solution

$all_ok = $True

task qir-runtime -precondition { $Env:ENABLE_QIRRUNTIME -ne "false" } {
    exec -workingDirectory (Join-Path $PSScriptRoot ".." "src" "Qir" "Runtime") {
        Invoke-psake -buildFile "./build-qir-stdlib.ps1"
    }
}

task native-simulation -depends full-simulator, sparse-simulator -precondition { $Env:ENABLE_NATIVE -ne "false" }

task full-simulator -precondition { $Env:ENABLE_NATIVE -ne "false" } {
    exec -workingDirectory (Join-Path $PSScriptRoot ".." "src" "Simulation" "Native") {
        Invoke-psake -buildFile "./build-native-simulator.ps1"
    }
}

task sparse-simulator -precondition { $Env:ENABLE_NATIVE -ne "false" } {
    exec -workingDirectory (Join-Path $PSScriptRoot ".." "src" "Simulation" "NativeSparseSimulator") {
        Invoke-psake -buildFile "./build.ps1"
    }
}

function Test-CommandExists($name) {
    $null -ne (Get-Command $name -ErrorAction SilentlyContinue)
}

task experimental-simulator -precondition { $Env:ENABLE_EXPERIMENTALSIM -ne "false" } {
    if (-not (Test-CommandExists cargo)) {
        # Cargo was missing, so cannot build experimental simulators.
        # That's fine if running locally, we'll warn the user and then skip.
        # On CI, though, we should fail when the experimental simulator build
        # is turned on by ENABLE_EXPERIMENTALSIM, but we can't actually
        # proceed.
        
        Write-Warning `
            "Experimental simulators enabled, but cargo missing. " + `
            "Either install cargo, or set `$Env:ENABLE_EXPERIMENTALSIM " + `
            "to `"false`". Skipping experimental simulators.";
        Assert $IsCI "##[error]Experimental simulators enabled, but cargo was not installed in CI pipeline."
    } else {
        # Prerequisites are met, so let's go.
        $expSim = (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
        exec -workingDirectory $expSim { 
            Invoke-psake "./build-qdk-sim-rs.ps1"
        }
    }
}

task simulator-solution -depends simulator-solution-restore, simulator-solution-build

task simulator-solution-restore -depends set-env {
    exec {
        dotnet restore (Join-Path $PSScriptRoot ".." "Simulation.sln" -Resolve)
    }
}

task simulator-solution-build -depends set-env {
    Build-One 'build' (Join-Path $PSScriptRoot ".." "Simulation.sln" -Resolve)
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
    exec -errorMessage "##vso[task.logissue type=error;]Failed to build $project." {
        dotnet $action $project `
            -c $Env:BUILD_CONFIGURATION `
            -v $Env:BUILD_VERBOSITY  `
            @args `
            /property:Version=$Env:ASSEMBLY_VERSION `
            /property:QSharpDocsOutputPath=$Env:DOCS_OUTDIR;
    }
}

# if ($Env:ENABLE_QIRRUNTIME -ne "false") {
#     $qirTests = (Join-Path $PSScriptRoot "../src/Qir/Tests")
#     & "$qirTests/build-qir-tests.ps1" -SkipQSharpBuild
#     if ($LastExitCode -ne 0) {
#         $script:all_ok = $False
#     }
#     $qirSamples = (Join-Path $PSScriptRoot "../src/Qir/Samples")
#     & "$qirSamples/build-qir-samples.ps1" -SkipQSharpBuild
#     if ($LastExitCode -ne 0) {
#         $script:all_ok = $False
#     }
# } else {
#     Write-Host "Skipping build of qir tests because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME"
# }

# if (-not $all_ok) {
#     throw "At least one project failed to compile. Check the logs."
# }
