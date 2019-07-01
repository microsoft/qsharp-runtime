# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

.\set-env.ps1

Write-Host "##[info]Build Native simulator"
cmake --build ../src/Simulation/Native/build `
    --config $BUILD_CONFIGURATION
if ($LastExitCode -ne 0) { throw "Cannot build Native simulator." }


function Build-One {
    Param($action, $project)

    dotnet $action $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:QsharpDocsOutDir=$Env:DOCS_OUTDIR

    if ($LastExitCode -ne 0) { throw "Cannot $action $project." }
}

Write-Host "##[info]Build C# code generation"
Build-One 'publish' '../src/Simulation/CsharpGeneration.App'

Write-Host "##[info]Build Q# simulation"
Build-One 'build' '../Simulation.sln'

