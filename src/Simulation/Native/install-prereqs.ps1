# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (($IsMacOS) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Darwin")))) {
    Write-Host "Install gcc as pre-req for building native simulator on MacOS"
    brew install gcc@9
} else {
    Write-Host "No pre-reqs for building native simulator on platforms other than MacOS"
}



