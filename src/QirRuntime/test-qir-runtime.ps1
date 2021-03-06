# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_NATIVE -ne "false") {
    if ($Env:ENABLE_QIRRUNTIME -eq "true") {
        Write-Host "##[info]Test QIR Runtime"

        Push-Location (Join-Path $PSScriptRoot build $Env:BUILD_CONFIGURATION test)

        ctest --verbose

        if ($LastExitCode -ne 0) {
            Write-Host "##vso[task.logissue type=error;]Failed to test QIR Runtime"
            $script:all_ok = $False
        }

        Pop-Location
    } else {
        Write-Host "Skipping testing qir runtime because ENABLE_QIRRUNTIME variable set to: $Env:ENABLE_QIRRUNTIME."
    }
} else {
    Write-Host "Skipping native components because ENABLE_NATIVE variable set to: $Env:ENABLE_NATIVE."
}
