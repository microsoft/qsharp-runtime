# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

[CmdletBinding()]
param (
    [Parameter()]
    [Switch]
    $SkipQSharpBuild
)

Write-Host "##[info]Compile Q# Sample Projects into QIR"

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

& "$PSScriptRoot/../check-sources-formatted.ps1" $PSScriptRoot

Build-QirProject (Join-Path $PSScriptRoot StandaloneInputReference qsharp) -SkipQSharpBuild:$SkipQSharpBuild

if (-not (Build-CMakeProject $PSScriptRoot "QIR Samples")) {
    throw "At least one project failed to compile. Check the logs."
}