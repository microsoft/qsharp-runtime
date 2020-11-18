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

if ($Env:ENABLE_QIRRUNTIME -eq "true") {
    Push-Location (Join-Path $PSScriptRoot "src/QirRuntime")
        .\install-prereqs.ps1
    Pop-Location
} else {
    Write-Host "Skipping installing prerequisites for qir runtime because ENABLE_QIRRUNTIME variable set to: $Env:ENABLE_QIRRUNTIME."
}

# bootstrap native folder
if ($Env:ENABLE_NATIVE -ne "false") {
    ## Run the right script based on the OS.
    if (-not (Test-Path Env:AGENT_OS) -or ($Env:AGENT_OS.StartsWith("Win"))) {
        .\bootstrap.cmd
    } else {
        .\bootstrap.sh
    }
} else {
    Write-Host "Skipping native. ENABLE_NATIVE variable set to: $Env:ENABLE_NATIVE."
}