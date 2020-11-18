# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'
& "$PSScriptRoot/build/set-env.ps1"

Push-Location (Join-Path $PSScriptRoot "src/Simulation/CsharpGeneration")
    .\FindNuspecReferences.ps1
Pop-Location

Push-Location (Join-Path $PSScriptRoot "src/Simulation/Simulators")
    .\FindNuspecReferences.ps1
Pop-Location

# At the moment the QIR Runtime build isn't enabled locally by default.
if ($Env:ENABLE_QIRRUNTIME -eq "true") {
    Push-Location (Join-Path $PSScriptRoot "src/QirRuntime")
        .\install-prereqs.ps1
    Pop-Location
} else {
    Write-Host "Skipping installing prerequisites for qir runtime because ENABLE_QIRRUNTIME variable set to: $Env:ENABLE_QIRRUNTIME."
}

