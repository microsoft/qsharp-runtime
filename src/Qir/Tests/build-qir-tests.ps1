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

Build-QirProject (Join-Path $PSScriptRoot QIR-static qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot QIR-dynamic qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot QIR-tracer qsharp) -SkipQSharpBuild:$SkipQSharpBuild
Build-QirProject (Join-Path $PSScriptRoot FullstateSimulator qsharp) -SkipQSharpBuild:$SkipQSharpBuild

if (-not (Build-CMakeProject $PSScriptRoot "QIR Tests")) {
    throw "At least one project failed to compile. Check the logs."
}