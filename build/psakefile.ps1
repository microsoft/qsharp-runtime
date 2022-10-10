# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

$ErrorActionPreference = 'Stop'

Include (Join-Path $PSScriptRoot "set-env.ps1")
Include (Join-Path $PSScriptRoot "azure-devops.ps1")
Include (Join-Path $PSScriptRoot "utils.ps1")
#Include (Join-Path $PSScriptRoot "test.ps1")
#Include (Join-Path $PSScriptRoot "prerequisites.ps1")
Include (Join-Path $PSScriptRoot "../src/Simulation/Simulators/FindNuspecReferences.ps1")

TaskSetup {
    param($task)
    
    Write-GroupBegin "$($task.Name)"
}

TaskTearDown {
    param($task)
    if ($task.Success) {
        Write-Information "Task $($task.Name) - success!"
    } else {
        Write-Information "Task $($task.Name) - failed: $($task.ErrorMessage)"
    }
    Write-GroupEnd
}

task bootstrap -depends prerequisites, find-nuspec-references

task prerequisites {
    Invoke-psake -buildFile "prerequisites.ps1"
}

task default -depends set-env, qir-runtime, full-simulator, sparse-simulator, experimental-simulator, simulator-solution, qir-verification

task pack -depends set-env {
    & (Join-Path $PSScriptRoot "pack.ps1")
}

task manifest -depends set-env {
    & (Join-Path $PSScriptRoot "manifest.ps1")
}

task test -depends set-env {
    Invoke-psake (Join-Path $PSScriptRoot "test.ps1")
}

task qir-runtime -precondition { $Env:ENABLE_QIRRUNTIME -ne "false" } {
    exec -workingDirectory (Join-Path $PSScriptRoot ".." "src" "Qir" "Runtime") {
        Invoke-psake -buildFile "./build-qir-stdlib.ps1"
    }
}

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

task qir-verification -depends qir-tests, qir-samples -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") }

task qir-tests -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") } {
    $qirTests = (Join-Path $PSScriptRoot "../src/Qir/Tests" -Resolve)
    exec {
        & "$qirTests/build-qir-tests.ps1" -SkipQSharpBuild
    }
}

task qir-samples -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") } {
    $qirSamples = (Join-Path $PSScriptRoot "../src/Qir/Samples" -Resolve)
    exec {
        & "$qirSamples/build-qir-samples.ps1" -SkipQSharpBuild
    }
}
