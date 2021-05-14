# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

if (-not (Test-Path Env:AGENT_OS)) {
    if ($Env:ENABLE_NATIVE -ne "false") {
        Write-Host "Build release flavor of the native simulator"
        $Env:BUILD_CONFIGURATION = "Release"
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
            .\build-native-simulator.ps1
        Pop-Location
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/qdk_sim")
            .\build-qdk-sim-rs.ps1
        Pop-Location
        $Env:BUILD_CONFIGURATION = $null
    }

    Write-Host "Build simulation solution"
    dotnet build Simulation.sln
}
