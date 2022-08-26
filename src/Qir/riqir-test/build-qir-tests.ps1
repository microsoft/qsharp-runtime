# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $SkipQSharpBuild
)

Write-Host "##[info]Compile Q# Test Projects into QIR"

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

& (Join-Path $PSScriptRoot ".." check-sources-formatted.ps1) -Path $PSScriptRoot

Build-QirProject (Join-Path $PSScriptRoot .. Tests QIR-static qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot .. Tests QIR-dynamic qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot .. Tests QIR-tracer qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot .. Tests FullstateSimulator qsharp) -SkipQSharpBuild:$SkipQSharpBuild

if (-not (Build-CMakeProject $PSScriptRoot "RIQIR Tests")) {
    throw "At least one project failed to compile. Check the logs."
}