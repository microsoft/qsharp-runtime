# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

Write-Host "##[info]Test Native Sparse Simulator"
Push-Location (Join-Path $PSScriptRoot "build")

ctest -C "$Env:BUILD_CONFIGURATION" --verbose

$RetVal = $LastExitCode

if ($RetVal -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test Native Sparse Simulator"
}

Pop-Location

Exit $RetVal
