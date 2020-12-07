# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator for $Env:BUILD_CONFIGURATION"


$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

# There should be no space after -DCMAKE_BUILD_TYPE= but if we provide the environment variable inline, without
# the space it doesn't seem to get substituted... With invalid -DCMAKE_BUILD_TYPE argument cmake silently produces
# a DEBUG build.
if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    Write-Host "On Windows build native simulator using the default C/C++ compiler (should be MSVC)"
    cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    Write-Host "On Linux build native simulator using gcc (needed for OpenMP)"
    cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_C_COMPILER=gcc -DCMAKE_CXX_COMPILER=g++ -DCMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
elseif (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    Write-Host "On MacOS build native simulator using gcc (needed for OpenMP)"
    # `gcc`on Darwin seems to be a shim that redirects to AppleClang, to get real gcc, must point to the specific
    # version of gcc we've installed.
    cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_C_COMPILER=gcc-7 -DCMAKE_CXX_COMPILER=g++-7 -DCMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
else {
    cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_BUILD_TYPE="$Env:BUILD_CONFIGURATION" ..
}
cmake --build . --config "$Env:BUILD_CONFIGURATION" --target install

Pop-Location


if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}

