# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_QIRRUNTIME -eq "true") {
    if (-not (Test-Path Env:AGENT_OS) -or ($Env:AGENT_OS.StartsWith("Win"))) {
        choco install llvm
        choco install ninja
    } else {
        #brew install llvm  # this seems to mess up native simulator build, probably because of STD libs
                            # llvm should be already available on later Linux systems
        brew install ninja
    }
} else {
    Write-Host "Skipping installing prerequisites for qir runtime because ENABLE_QIRRUNTIME variable set to: $Env:ENABLE_QIRRUNTIME."
}
