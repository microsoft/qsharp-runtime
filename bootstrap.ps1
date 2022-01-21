# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

cargo install cargo-edit
Push-Location (Join-Path $PSScriptRoot "./src/Simulation/qdk_sim_rs")
    cargo set-version $Env:NUGET_VERSION;
Pop-Location

if (-not (Test-Path Env:/AGENT_OS)) {                                    # If not CI build, i.e. local build (if AGENT_OS envvar is not defined)
    if ($Env:ENABLE_NATIVE -ne "false") {
        Write-Host "Build release flavor of the native simulator"
        $Env:BUILD_CONFIGURATION = "Release"
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
            .\build-native-simulator.ps1
        Pop-Location
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/qdk_sim_rs")
            # Don't run the experimental simulator build if we're local
            # and prerequisites are missing.
            $IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";
            if ((Get-Command cargo -ErrorAction SilentlyContinue) -or $IsCI) {
                .\build-qdk-sim-rs.ps1
            } else {
                Write-Verbose "cargo was not installed, skipping qdk_sim_rs build.";
            }
        Pop-Location
        $Env:BUILD_CONFIGURATION = $null
    }
    if ($Env:ENABLE_QIRRUNTIME -ne "false") {
        Write-Host "Build release flavor of the QIR Runtime"
        $Env:BUILD_CONFIGURATION = "Release"
        Push-Location (Join-Path $PSScriptRoot "src/Qir/Runtime")
            .\build-qir-runtime.ps1
        Pop-Location
        $Env:BUILD_CONFIGURATION = $null
    }

    Write-Host "Build simulation solution"
    dotnet build Simulation.sln
}
