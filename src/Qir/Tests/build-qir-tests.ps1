# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $SkipQSharpBuild
)

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

Write-Host "##[info]Compile Q# Projects into QIR"
Build-QirProject (Join-Path $PSScriptRoot QIR-static qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot QIR-dynamic qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot QIR-tracer qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot FullstateSimulator qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot Type1Simulator qsharp) -SkipQSharpBuild:$SkipQSharpBuild

if (-not (Build-CMakeProject $PSScriptRoot "QIR Tests")) {
    throw "At least one project failed to compile. Check the logs."
}