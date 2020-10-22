# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Test Native simulator"
Push-Location (Join-Path $PSScriptRoot "../src/Simulation/Native/build")
cmake --build . --config $Env:BUILD_CONFIGURATION
ctest -C $Env:BUILD_CONFIGURATION --verbose
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test Native Simulator"
    $script:all_ok = $False
}
Pop-Location
