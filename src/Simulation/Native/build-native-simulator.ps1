# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

Write-Host "##[info]Build Native simulator"

$oldCC = $env:CC
$oldCXX = $env:CXX

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin"))))
{
    $env:CC = "/usr/bin/gcc"
    $env:CXX = "/usr/bin/g++"
}
elseif (($IsLinux) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Lin"))))
{
    $env:CC = "/usr/bin/gcc"
    $env:CXX = "/usr/bin/g++"
}
elseif (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win"))))
{
    # use default, which should be MSVC
} else {
    Write-Host "##vso[task.logissue type=error;]Failed to identify the OS. Will use default CXX compiler"
}

$nativeBuild = (Join-Path $PSScriptRoot "build")
if (-not (Test-Path $nativeBuild)) {
    New-Item -Path $nativeBuild -ItemType "directory"
}
Push-Location $nativeBuild

cmake -DBUILD_SHARED_LIBS:BOOL="1" -DCMAKE_BUILD_TYPE= $Env:BUILD_CONFIGURATION ..
cmake --build . --config $Env:BUILD_CONFIGURATION

Pop-Location

$env:CC = $oldCC
$env:CXX = $oldCXX

if ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to build Native simulator."
}

