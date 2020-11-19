# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator"

$compiler = ""
if (Test-Path Env:AGENT_OS) {
    if ($Env:AGENT_OS.StartsWith("Darwin")) {
        $compiler = "-DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7"
        Write-Host "The system is identified as MacOS: $IsMacOS"
    }
} else {
    Write-Host "Native Simulator should be built on MacOS using gcc7."
}

$nativeBuild = (Join-Path $PSScriptRoot "build\$Env:BUILD_CONFIGURATION")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

cmake $compiler -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_BUILD_TYPE= $BuildConfiguration ../..
cmake --build .

Pop-Location

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}

