# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

Push-Location (Join-Path $PSScriptRoot "./src/Simulation/qdk_sim_rs")
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

if (-not (Test-Path Env:AGENT_OS)) {
    if ($Env:ENABLE_NATIVE -ne "false") {
        Write-Host "Build release flavor of the native simulator"
        $Env:BUILD_CONFIGURATION = "Release"
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
            .\build-native-simulator.ps1
        Pop-Location
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/qdk_sim_rs")
            .\build-qdk-sim-rs.ps1
        Pop-Location
        $Env:BUILD_CONFIGURATION = $null
    }

    Write-Host "Build simulation solution"
    dotnet build Simulation.sln
}
