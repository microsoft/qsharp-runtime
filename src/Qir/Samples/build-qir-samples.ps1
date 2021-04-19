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
Build-QirProject (Join-Path $PSScriptRoot StandaloneInputReference qsharp) -SkipQSharpBuild:$SkipQSharpBuild

if (-not (Build-CMakeProject $PSScriptRoot "QIR Samples")) {
    throw "At least one project failed to compile. Check the logs."
}