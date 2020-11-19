# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
    # building with gcc-9 succeeds but some of the unit tests fail
    Write-Host "Install gcc-7 as pre-req for building native simulator on MacOS"
    brew install gcc@7
} else {
    Write-Host "No pre-reqs for building native simulator on platforms other than MacOS"
}



