# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

if (-not (Build-CMakeProject $PSScriptRoot "QIR Runtime")) {
    throw "At least one project failed to compile. Check the logs."
}

# Copy the results of runtime compilation and the corresponding headers to the drops folder so
# they can be included in pipeline artifacts.
$qirDropsFolder = (Join-Path $Env:DROPS_DIR QIR)
$qirDropsBin = (Join-Path $qirDropsFolder bin)
$qirDropsInclude = (Join-Path $qirDropsFolder include)
if (-not (Test-Path $qirDropsFolder)) {
    New-Item -Path $qirDropsFolder -ItemType "directory"
    New-Item -Path $qirDropsBin -ItemType "directory"
    New-Item -Path $qirDropsInclude -ItemType "directory"
}
$qirBinaries = (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION bin *)
$qirIncludes = (Join-Path $PSScriptRoot public *)
Copy-Item $qirBinaries $qirDropsBin
Copy-Item $qirIncludes $qirDropsInclude