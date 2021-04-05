# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

. (Join-Path $PSScriptRoot .. qir-utils.ps1)

if (-not (Build-CMakeProject $PSScriptRoot "QIR Runtime")) {
    throw "At least one project failed to compile. Check the logs."
}
