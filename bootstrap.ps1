# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

$ErrorActionPreference = 'Stop'

& (Join-Path $PSScriptRoot "build.ps1" -Resolve) -t bootstrap
