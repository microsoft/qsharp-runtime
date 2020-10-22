# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

if ($Env:ENABLE_NATIVE -ne "false") {
    if ($Env:ENABLE_QIRRUNTIME -eq "true") {
        Write-Host "##[info]Test QIR Runtime"
        $qirRuntimeBuild = (Join-Path $PSScriptRoot "../src/QirRuntime/build")
        $qirRuntimeBuild = (Join-Path $qirRuntimeBuild $Env:BUILD_CONFIGURATION)
        if (-not (Test-Path Env:AGENT_OS) -or ($Env:AGENT_OS.StartsWith("Win"))) {
            $qdkPath = (Join-Path $qirRuntimeBuild "lib/QAPI")
            $fullSimPath = (Join-Path $PSScriptRoot "../src/QirRuntime/externals/QuantumSimulator")
            $Env:PATH = $Env:PATH + ";" + $fullSimPath + ";" + $qdkPath
            Write-Host $Env:PATH
        }
        Push-Location ($qirRuntimeBuild)
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
