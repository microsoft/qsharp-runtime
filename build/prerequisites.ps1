# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/set-env.ps1"

Push-Location (Join-Path $PSScriptRoot "../src/Simulation/CSharpGeneration")
    .\FindNuspecReferences.ps1
Pop-Location

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

# At the moment the QIR Runtime build isn't enabled locally by default.
if ($Env:ENABLE_QIRRUNTIME -eq "true") {
    Push-Location (Join-Path $PSScriptRoot "../src/QirRuntime")
        .\prerequisites.ps1
    Pop-Location
} else {
    Write-Host "Skipping installing prerequisites for qir runtime because ENABLE_QIRRUNTIME variable set to: $Env:ENABLE_QIRRUNTIME"
}

