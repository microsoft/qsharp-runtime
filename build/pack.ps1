# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

Write-Host "##[info]Copy Native simulator xplat binaries"
pushd ../src/Simulation/Native
If (-not (Test-Path 'osx')) { mkdir 'osx' }
If (-not (Test-Path 'linux')) { mkdir 'linux' }
$DROP="$Env:DROP_NATIVE/src/Simulation/Native/build"
If (Test-Path "$DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib") { copy "$DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib" "osx/Microsoft.Quantum.Simulator.Runtime.dll" }
If (Test-Path "$DROP/libMicrosoft.Quantum.Simulator.Runtime.so") { copy "$DROP/libMicrosoft.Quantum.Simulator.Runtime.so"  "linux/Microsoft.Quantum.Simulator.Runtime.dll" }
popd


function Pack-One() {
    Param($project, $option1="", $option2="", $option3="")
    nuget pack $project `
        -OutputDirectory $Env:NUGET_OUTDIR `
        -Properties Configuration=$Env:BUILD_CONFIGURATION `
        -Version $Env:NUGET_VERSION `
        -Verbosity detailed `
        -SymbolPackageFormat snupkg `
        $option1 `
        $option2 `
        $option3

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to pack $project"
        $script:all_ok = $False
    }
}

function Pack-One-Dotnet() {
    Param($project, $option1="", $option2="", $option3="")
    dotnet pack $project `
        -o $Env:NUGET_OUTDIR `
        -c $Env:BUILD_CONFIGURATION `
        -v detailed `
        /property:DefineConstants=$Env:ASSEMBLY_CONSTANTS `
        /property:Version=$Env:NUGET_VERSION `
        $option1 `
        $option2 `
        $option3

    if  ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to pack $project."
        $script:all_ok = $False
    }
}


Write-Host "##[info]Using nuget to create packages"
Pack-One '../src/Simulation/CsharpGeneration/Microsoft.Quantum.CsharpGeneration.fsproj' '-IncludeReferencedProjects'
Pack-One-Dotnet '../src/Simulation/Core/Microsoft.Quantum.Runtime.Core.csproj'
Pack-One-Dotnet '../src/Simulation/QsharpCore/Microsoft.Quantum.QSharp.Core.csproj'
Pack-One '../src/Simulation/Simulators/Microsoft.Quantum.Simulators.nuspec'
Pack-One '../src/Quantum.Development.Kit/Microsoft.Quantum.Development.Kit.nuspec'
Pack-One '../src/Xunit/Microsoft.Quantum.Xunit.csproj'

if (-not $all_ok) 
{
    throw "At least one project failed to pack. Check the logs."
}
