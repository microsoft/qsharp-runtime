# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Write-Host "##[info]Test Native simulator"
pushd (Join-Path $PSScriptRoot "../src/Simulation/Native/build")
cmake --build . --config $Env:BUILD_CONFIGURATION
ctest -C $Env:BUILD_CONFIGURATION
if  ($LastExitCode -ne 0) {
    Write-Host "##vso[task.logissue type=error;]Failed to test Native Simulator"
    $script:all_ok = $False
}
popd


function Test-One {
    Param($project)

    Write-Host "##[info]Testing $project..."
    Invoke-Expression ("dotnet test (Join-Path $PSScriptRoot $project) " +
        "-c $Env:BUILD_CONFIGURATION " +
        "-v $Env:BUILD_VERBOSITY " +
        "--logger trx " +
        "$(if ($Env:ASSEMBLY_CONSTANTS){"/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS"}) " +
        "/property:Version=$Env:ASSEMBLY_VERSION")

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to test $project"
        $script:all_ok = $False
    }
}

Test-One '../Simulation.sln'

if (-not $all_ok) 
{
    throw "At least one project failed during testing. Check the logs."
}
