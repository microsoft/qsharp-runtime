# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& (Join-Path $PSScriptRoot .. .. .. build set-env.ps1)
$all_ok = $true

Write-Host "##[info]Test QIR Runtime"

Push-Location (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION test)

ctest --verbose

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test QIR Runtime"
    $script:all_ok = $False
}

Pop-Location

Write-Host "##[info]Test QIR Standalone Sample"

Push-Location (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION samples StandaloneInputReference)

ctest --verbose

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test QIR Standalone Sample"
    $script:all_ok = $False
}

Pop-Location

if (-not $all_ok) {
    throw "At least one project failed testing. Check the logs."
}
