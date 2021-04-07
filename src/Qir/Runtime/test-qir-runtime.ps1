# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

if (-not (Test-CTest (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION unittests) "QIR Runtime")) {
    throw "At least one project failed testing. Check the logs."
}
