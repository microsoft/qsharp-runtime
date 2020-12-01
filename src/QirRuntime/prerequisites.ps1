# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_QIRRUNTIME -eq "true") {
    if (($IsWindows) -or ((Test-Path Env:AGENT_OS) -and ($Env:AGENT_OS.StartsWith("Win")))) {
        choco install llvm
        choco install ninja
    } else {
        #brew install llvm  # this seems to mess up native simulator build, probably because of STD libs
                            # llvm should be already available on later Linux/Darwin systems
        brew install ninja
    }
}

