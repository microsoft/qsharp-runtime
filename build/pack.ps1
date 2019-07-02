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
    Param($project, $include_references="")
    nuget pack $project `
        -OutputDirectory $Env:NUGET_OUTDIR `
        -Properties Configuration=$Env:BUILD_CONFIGURATION `
        -Version $Env:NUGET_VERSION `
        -Verbosity detailed `
        $include_references

    $script:all_ok = ($LastExitCode -eq 0) -and $script:all_ok
}


Write-Host "##[info]Using nuget to create packages"
Pack-One '../src/Simulation/CsharpGeneration/Microsoft.Quantum.CsharpGeneration.fsproj' '-IncludeReferencedProjects'
Pack-One '../src/Simulation/Simulators/Microsoft.Quantum.Simulators.csproj' '-IncludeReferencedProjects'
Pack-One '../src/ProjectTemplates/Microsoft.Quantum.ProjectTemplates.nuspec'
Pack-One '../src/Microsoft.Quantum.Development.Kit.nuspec'
Pack-One '../src/Xunit/Microsoft.Quantum.Xunit.csproj'

if (-not $all_ok) 
{
    throw "At least one project failed to compile. Check the logs."
}
