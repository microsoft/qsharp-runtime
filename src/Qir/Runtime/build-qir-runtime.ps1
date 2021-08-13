# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

& "$PSScriptRoot/../check-sources-formatted.ps1" $PSScriptRoot
& "$PSScriptRoot/../check-sources-formatted.ps1" $PSScriptRoot/../Common

if (-not (Build-CMakeProject $PSScriptRoot "QIR Runtime")) {
    throw "At least one project failed to compile. Check the logs."
}

# Copy the results of runtime compilation and the corresponding headers to the QIR drops folder so
# they can be included in pipeline artifacts.
$osDir = "win-x64"
if ($IsLinux) {
    $osDir = "linux-x64"
} elseif ($IsMacOS) {
    $osDir = "osx-x64"
}
$qirDropsBin = (Join-Path $Env:QIR_DROPS bin $osDir native)
$qirDropsInclude = (Join-Path $Env:QIR_DROPS include)
if (-not (Test-Path $Env:QIR_DROPS)) {
    New-Item -Path $Env:QIR_DROPS -ItemType "directory"
    New-Item -Path $qirDropsBin -ItemType "directory"
    New-Item -Path $qirDropsInclude -ItemType "directory"
}
$qirBinaries = (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION bin *)
$qirIncludes = (Join-Path $PSScriptRoot public *)
Copy-Item $qirBinaries $qirDropsBin -Exclude "*unittests*","*.Tracer.*"
Copy-Item $qirIncludes $qirDropsInclude -Exclude "*.md","Tracer*"