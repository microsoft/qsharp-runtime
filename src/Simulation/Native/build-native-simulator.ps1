# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator"
$nativeBuild = (Join-Path $PSScriptRoot "build")
cmake --build $nativeBuild --config $Env:BUILD_CONFIGURATION
if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}

