# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

.\set-env.ps1

Write-Host "##[info]Test Native simulator"
pushd ../src/Simulation/Native/build
ctest -C $BUILD_CONFIGURATION
popd


function Test-One {
    Param($project)

    dotnet test $project `
        -c $Env:BUILD_CONFIGURATION `
        -v $Env:BUILD_VERBOSITY `
        --logger trx `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:ASSEMBLY_VERSION

    if ($LastExitCode -ne 0) { throw "Cannot test $project." }
}

Write-Host "##[info]Testing C# code generation"
Test-One '../src/Simulation/CsharpGeneration.Tests/Tests.CsharpGeneration.fsproj'

Write-Host "##[info]Testing Roslyn Wrapper"
Test-One '../src/Simulation/RoslynWrapper.Tests/Tests.RoslynWrapper.fsproj'

Write-Host "##[info]Testing Tracer"
Test-One '../src/Simulation/QCTraceSimulator.Tests/Tests.Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.csproj'

Write-Host "##[info]Testing Q# Simulators"
Test-One '../src/Simulation/Simulators.Tests/Tests.Microsoft.Quantum.Simulation.Simulators.csproj'

