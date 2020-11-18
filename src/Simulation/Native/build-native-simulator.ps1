# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator"

$nativeBuild = (Join-Path $PSScriptRoot "build\$Env:BUILD_CONFIGURATION")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

cmake -DBUILD_SHARED_LIBS:BOOL="1" ../..
cmake --build .

Pop-Location

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}

