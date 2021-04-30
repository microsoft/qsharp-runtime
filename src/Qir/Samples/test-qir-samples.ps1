# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

if (-not (Test-CTest (Join-Path $PSScriptRoot bin $Env:BUILD_CONFIGURATION StandaloneInputReference) "QIR Samples (StandaloneInputReference)")) {
    throw "At least one project failed testing. Check the logs."
}
