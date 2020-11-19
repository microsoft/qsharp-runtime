# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if (Test-Path Env:AGENT_OS) {
    if ($Env:AGENT_OS.StartsWith("Win")) {
        choco install llvm
        choco install ninja
    } else {
        #brew install llvm  # this seems to mess up native simulator build, probably because of STD libs
                            # llvm should be already available on later Linux systems
        brew install ninja
    }
} else {
    Write-Host "Pre-reqs for building QIR Runtime include clang, ninja and some llvm tools. Please see readme for more details"
}

