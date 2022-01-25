# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Write-Host "##[info]Test Native Sparse Simulator"
#Push-Location (Join-Path $PSScriptRoot "build")
Push-Location (Join-Path $PSScriptRoot "build" $Env:BUILD_CONFIGURATION)

ctest -C "$Env:BUILD_CONFIGURATION" --verbose

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test Native Sparse Simulator"
    $script:all_ok = $False
}

Pop-Location
