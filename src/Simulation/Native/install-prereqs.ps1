# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (Test-Path Env:AGENT_OS) {
    if ($Env:AGENT_OS.StartsWith("Darwin")) {
        brew install gcc@7
    }
} else {
    Write-Host "To build native simulator on MacOS please install "
}


