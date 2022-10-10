# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

Properties {
    $tests = @{}
    $tests.errors = @()
}

function Exec-Test {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [scriptblock]$cmd,
        [string]$errorMessage
    )
    $global:lastexitcode = 0
    & $cmd
    if ($global:lastexitcode -ne 0) {
        Write-LogIssueError "Failed to test $project"
        $tests.all_ok = $False
    }
}

# Provide more error information when crashing during tests.
$Env:RUST_BACKTRACE = "1";

task test -depends test-native-sparse-simulator, test-simulation-solution, test-qir, test-experimental-simulator {
    $msg = "At least one project failed during testing. Check the logs."
    Assert (-not $tests.all_ok) $msg
}

task test-native-sparse-simulator -depends set-env -precondition { ($Env:ENABLE_NATIVE -ne "false") } {
    ( & (Join-Path $PSScriptRoot .. src Simulation NativeSparseSimulator test.ps1 ) ) || ( $script:all_ok = $False )

    $nativeSimulator = (Join-Path $PSScriptRoot "../src/Simulation/Native")
    Exec-Test -errorMessage "Native simulator tests failed." {
        & "$nativeSimulator/test-native-simulator.ps1"
    } 
}

function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    if ("" -ne "$Env:ASSEMBLY_CONSTANTS") {
        $args = @("/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS");
    }
    else {
        $args = @();
    }
    Exec-Test -errorMessage "Failed to test $project." {
        dotnet test $(Join-Path $PSScriptRoot $project) `
            -c $Env:BUILD_CONFIGURATION `
            -v $Env:BUILD_VERBOSITY `
            --logger trx `
            @args `
            /property:Version=$Env:ASSEMBLY_VERSION
    }
}

task test-simulation-solution -depends set-env {
    Test-One '../Simulation.sln'
}

task test-qir -depends set-env, test-qir-stdlib, test-qir-tests, test-qir-samples -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") }

task test-qir-stdlib -depends set-env -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") } {
    $qirStdLibPath = (Join-Path $PSScriptRoot .. src Qir Runtime test-qir-stdlib.ps1)
    Exec-Test -errorMessage "QIR stdlib tests failed." {
        & $qirStdLibPath
    }
}

task test-qir-tests -depends set-env -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") } {
    $qirTests = (Join-Path $PSScriptRoot "../src/Qir/Tests")
    Exec-Test -errorMessage "QIR tests failed." {
        & "$qirTests/test-qir-tests.ps1"
    }
}

task test-qir-samples -depends set-env -precondition { ($Env:ENABLE_QIRRUNTIME -ne "false") } {
    $qirSamples = (Join-Path $PSScriptRoot "../src/Qir/Samples")
    Exec-Test -errorMessage "QIR samples tests failed." {
        & "$qirSamples/test-qir-samples.ps1"
    }
}

task test-experimental-simulator -depends set-env -precondition { $Env:ENABLE_EXPERIMENTALSIM -ne "false" } {
    Exec-Test -errorMessage "Exerimental simulator tests failed." {
        $global:LASTEXITCODE = 1
    }

    # if (-not (Test-CommandExists cargo)) {
    #     # Cargo was missing, so cannot test experimental simulators.
    #     # That's fine if running locally, we'll warn the user and then skip.
    #     # On CI, though, we should fail when the experimental simulator build
    #     # is turned on by ENABLE_EXPERIMENTALSIM, but we can't actually
    #     # proceed.
    #     Write-Warning `
    #         "Experimental simulators enabled, but cargo missing. " + `
    #         "Either install cargo, or set `$Env:ENABLE_EXPERIMENTALSIM " + `
    #         "to `"false`". Skipping experimental simulators.";
    #     Assert $IsCI "##[error]Experimental simulators enabled, but cargo was not installed in CI pipeline."
    # }
    # else {
    #     $expSim = (Join-Path $PSScriptRoot "../src/Simulation/qdk_sim_rs")
    #     Exec-Test -errorMessage "Exerimental simulator tests failed." {
    #         & "$expSim/test-qdk-sim-rs.ps1"
    #     }
    # }
}
