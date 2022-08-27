# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

Write-Host "##[info]Compile QIR Runtime"

& (Join-Path $PSScriptRoot ".." check-sources-formatted.ps1) -Path $PSScriptRoot
& (Join-Path $PSScriptRoot ".." check-sources-formatted.ps1) -Path (Join-Path $PSScriptRoot ".." Common)

if (-not (Build-CMakeProject $PSScriptRoot "QIR Runtime")) {
    throw "At least one project failed to compile. Check the logs."
}

# Copy the results of runtime compilation and the corresponding headers to the QIR drops folder so
# they can be included in pipeline artifacts.
$qirDropsBin = (Join-Path $Env:QIR_DROPS bin $env:BUILD_PLATFORM native)
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