# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

If ($Env:NATIVE_SIMULATOR_BUILD_CONFIGURATION -eq $null) {
    $Env:NATIVE_SIMULATOR_BUILD_CONFIGURATION = "Release"
}

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

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
