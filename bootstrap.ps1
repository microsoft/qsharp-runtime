# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

$Env:NATIVE_SIMULATOR_BUILD_CONFIGURATION = "Release"

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

# Temporary hack until switch qdk build pipeline to use the new build scripts (as a result it will build the native 
# simulator twice, but the second build should be mostly noop)
if ((Test-Path Env:AGENT_OS) -and ($Env:CI -ne "true") -and ($Env:ENABLE_NATIVE -ne "false")) {
    Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
        .\build-native-simulator.ps1
    Pop-Location
}

# When setting up local dev environment, build Release version of the native simulator and Debug version of the managed
# part of the runtime.
if (-not (Test-Path Env:AGENT_OS)) {
    if ($Env:ENABLE_NATIVE -ne "false") {
        Write-Host "Build release flavor of the native simulator"
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
            .\build-native-simulator.ps1
        Pop-Location
    }

    Write-Host "Build simulation solution"
    dotnet build Simulation.sln
}
