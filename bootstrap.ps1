# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

Push-Location (Join-Path $PSScriptRoot "build")
    .\prerequisites.ps1
Pop-Location

# Temporary hack until switch qdk build pipeline to use the new build scripts (as a result it will build the native 
# simulator twice, but the second build should be mostly noop)
if (($Env:CI -eq $null) -and ($Env:ENABLE_NATIVE -ne "false")) {
    Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
        .\build-native-simulator.ps1
    Pop-Location
}

if (-not (Test-Path Env:AGENT_OS)) {
    if ($Env:ENABLE_NATIVE -ne "false") {
        Write-Host "Build release flavor of the native simulator"
        $Env:BUILD_CONFIGURATION = "Release"
        Push-Location (Join-Path $PSScriptRoot "src/Simulation/Native")
            .\build-native-simulator.ps1
        Pop-Location
    }

    Write-Host "Build simulation solution"
    dotnet build Simulation.sln
}
