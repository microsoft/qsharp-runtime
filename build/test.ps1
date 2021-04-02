# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

if ($Env:ENABLE_NATIVE -ne "false") {
    $nativeSimulator = (Join-Path $PSScriptRoot "../src/Simulation/Native")
    & "$nativeSimulator/test-native-simulator.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping test of native simulator because ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}
function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    if ("" -ne "$Env:ASSEMBLY_CONSTANTS") {
        $args = @("/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS");
    }  else {
        $args = @();
    }
    dotnet test $(Join-Path $PSScriptRoot $project) `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --logger trx `
        @args `
        /property:Version=$Env:ASSEMBLY_VERSION

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to test $project"
        $script:all_ok = $False
    }
}

Test-One '../Simulation.sln'

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    $qirRuntime = (Join-Path $PSScriptRoot "../src/Qir/Runtime")
    & "$qirRuntime/test-qir-runtime.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }

    $qirController = (Join-Path $PSScriptRoot "../src/Qir/Controller")
    & "$qirController/test-controller.ps1"
    if ($LastExitCode -ne 0) {
        $script:all_ok = $False
    }
} else {
    Write-Host "Skipping test of qir runtime because ENABLE_QIRRUNTIME variable is set to: $Env:ENABLE_QIRRUNTIME `
                and ENABLE_NATIVE variable is set to: $Env:ENABLE_NATIVE."
}

if (-not $all_ok) {
    throw "At least one project failed during testing. Check the logs."
}
