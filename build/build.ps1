# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Write-Host "##[info]Build Native simulator"
cmake --build (Join-Path $PSScriptRoot "../src/Simulation/Native/build") --config $Env:BUILD_CONFIGURATION
$script:all_ok = ($LastExitCode -eq 0) -and $script:all_ok


function Build-One {
    param(
        [string]$action,
        [string]$project
    );

    Write-Host "##[info]Building $project ($action)..."
    dotnet $action (Join-Path $PSScriptRoot $project) `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QsharpDocsOutDir=$Env:DOCS_OUTDIR

    $script:all_ok = ($LastExitCode -eq 0) -and $script:all_ok
}

Build-One 'publish' '../src/Simulation/CsharpGeneration.App'

Build-One 'build' '../Simulation.sln'

if (-not $all_ok) 
{
    throw "At least one project failed to compile. Check the logs."
}

