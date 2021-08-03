# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/set-env.ps1"

Push-Location (Join-Path $PSScriptRoot "../src/Simulation/Simulators")
    .\FindNuspecReferences.ps1
Pop-Location

# Native Quantum Simulator pre-reqs
if ($Env:ENABLE_NATIVE -ne "false") {
    Push-Location (Join-Path $PSScriptRoot "../src/Simulation/Native")
        .\prerequisites.ps1
    Pop-Location
} else {
    Write-Host "Skipping installing prerequisites for native simulator because ENABLE_NATIVE variable set to: $Env:ENABLE_NATIVE"
}

Push-Location (Join-Path $PSScriptRoot "../src/Qir/Runtime")
    .\prerequisites.ps1
Pop-Location
