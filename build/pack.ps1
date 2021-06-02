# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

& "$PSScriptRoot/set-env.ps1"
$all_ok = $True

$RepoRoot = Resolve-Path (Join-Path $PSScriptRoot "..");

Write-Host "##[info]Copy Native simulator xplat binaries"
pushd (Join-Path $PSScriptRoot ../src/Simulation/Native)
    If (-not (Test-Path 'osx')) { mkdir 'osx' }
    If (-not (Test-Path 'linux')) { mkdir 'linux' }
    If (-not (Test-Path 'win10')) { mkdir 'win10' }

    $DROP = "$Env:DROP_NATIVE/src/Simulation/Native/build/drop"
    If (Test-Path "$DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib") { copy "$DROP/libMicrosoft.Quantum.Simulator.Runtime.dylib" "osx/Microsoft.Quantum.Simulator.Runtime.dll" }
    If (Test-Path "$DROP/libMicrosoft.Quantum.Simulator.Runtime.so") { copy "$DROP/libMicrosoft.Quantum.Simulator.Runtime.so"  "linux/Microsoft.Quantum.Simulator.Runtime.dll" }

    $DROP = "$Env:DROP_NATIVE/qdk_sim_rs";
    if (Test-Path "$DROP/libqdk_sim.dylib") {
        Copy-Item "$DROP/libqdk_sim.dylib" "osx/Microsoft.Quantum.Experimental.Simulators.Runtime.dll"
    }
    if (Test-Path "$DROP/libqdk_sim.so") {
        Copy-Item "$DROP/libqdk_sim.so" "linux/Microsoft.Quantum.Experimental.Simulators.Runtime.dll"
    }
    if (Test-Path "$DROP/qdk_sim.dll") {
        Copy-Item "$DROP/qdk_sim.dll"  "win10/Microsoft.Quantum.Experimental.Simulators.Runtime.dll"
    }
Pop-Location


function Pack-One() {
    Param(
        $project, 
        $option1 = "",
        $option2 = "",
        $option3 = "",
        [switch]$ForcePrerelease
    )

    if ($ForcePrerelease) {
        $version = ($Env:NUGET_VERSION -split "-")[0] + "-alpha"
    } else {
        $version = $Env:NUGET_VERSION
    }

    nuget pack (Join-Path $PSScriptRoot $project) `
        -OutputDirectory $Env:NUGET_OUTDIR `
        -Properties Configuration=$Env:BUILD_CONFIGURATION `
        -Version $version `
        -Verbosity detailed `
        -SymbolPackageFormat snupkg `
        $option1 `
        $option2 `
        $option3

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to pack $project"
        $script:all_ok = $False
    }
}

function Pack-Dotnet() {
    Param(
        $project, 
        $option1 = "",
        $option2 = "",
        $option3 = "",
        [switch]$ForcePrerelease
    )

    if ("" -ne "$Env:ASSEMBLY_CONSTANTS") {
        $props = @("/property:DefineConstants=$Env:ASSEMBLY_CONSTANTS");
    }  else {
        $props = @();
    }

    if ($ForcePrerelease) {
        $version = ($Env:NUGET_VERSION -split "-")[0] + "-alpha"
    } else {
        $version = $Env:NUGET_VERSION
    }

    dotnet pack (Join-Path $PSScriptRoot $project) `
        -o $Env:NUGET_OUTDIR `
        -c $Env:BUILD_CONFIGURATION `
        -v detailed `
        --no-build `
        @props `
        /property:Version=$Env:ASSEMBLY_VERSION `
        /property:PackageVersion=$version `
        $option1 `
        $option2 `
        $option3

    if ($LastExitCode -ne 0) {
        Write-Host "##vso[task.logissue type=error;]Failed to pack $project."
        $script:all_ok = $False
    }
}


function Pack-Crate() {
    param(
        [string]
        $PackageDirectory,

        [string]
        $OutPath
    );

    "##[info]Packing crate at $PackageDirectory to $OutPath..." | Write-Host

    $releaseFlag = "$Env:BUILD_CONFIGURATION" -eq "Release" ? @("--release") : @();

    # Resolve relative to where the build script is located,
    # not the PackageDirectory.
    if (-not [IO.Path]::IsPathRooted($OutPath)) {
        $OutPath = Resolve-Path (Join-Path $PSScriptRoot $OutPath);
    }
    Push-Location (Join-Path $PSScriptRoot $PackageDirectory)
        cargo package @releaseFlag;
        Copy-Item -Force -Recurse (Join-Path . "target" "package") $OutPath;
    Pop-Location
}

function Pack-Wheel() {
    param(
        [string]
        $PackageDirectory,

        [string]
        $OutPath
    );

    "##[info]Packing wheel at $PackageDirectory to $OutPath..." | Write-Host

    # Resolve relative to where the build script is located,
    # not the PackageDirectory.
    if (-not [IO.Path]::IsPathRooted($OutPath)) {
        $OutPath = Resolve-Path (Join-Path $PSScriptRoot $OutPath);
    }
    Push-Location (Join-Path $PSScriptRoot $PackageDirectory)
        pip wheel --wheel-dir $OutPath .;
    Pop-Location
}

Write-Host "##[info]Using nuget to create packages"
Pack-Dotnet '../src/Azure/Azure.Quantum.Client/Microsoft.Azure.Quantum.Client.csproj'
Pack-One '../src/Simulation/CSharpGeneration/Microsoft.Quantum.CSharpGeneration.fsproj' '-IncludeReferencedProjects'
Pack-Dotnet '../src/Simulation/EntryPointDriver/Microsoft.Quantum.EntryPointDriver.csproj'
Pack-Dotnet '../src/Simulation/Core/Microsoft.Quantum.Runtime.Core.csproj'
Pack-Dotnet '../src/Simulation/TargetDefinitions/Interfaces/Microsoft.Quantum.Targets.Interfaces.csproj'
Pack-Dotnet '../src/Simulation/QSharpFoundation/Microsoft.Quantum.QSharp.Foundation.csproj'
Pack-Dotnet '../src/Simulation/QSharpCore/Microsoft.Quantum.QSharp.Core.csproj'
Pack-Dotnet '../src/Simulation/Type1Core/Microsoft.Quantum.Type1.Core.csproj'
Pack-Dotnet '../src/Simulation/Type2Core/Microsoft.Quantum.Type2.Core.csproj'
Pack-Dotnet '../src/Simulation/Type3Core/Microsoft.Quantum.Type3.Core.csproj'
Pack-One '../src/Simulation/Simulators/Microsoft.Quantum.Simulators.nuspec'
Pack-One '../src/Quantum.Development.Kit/Microsoft.Quantum.Development.Kit.nuspec'
Pack-One '../src/Xunit/Microsoft.Quantum.Xunit.csproj'
Pack-Crate -PackageDirectory "../src/Simulation/qdk_sim_rs" -OutPath $Env:CRATE_OUTDIR;
Pack-Wheel -PackageDirectory "../src/Simulation/qdk_sim_rs" -OutPath $Env:WHEEL_OUTDIR;
Pack-One '../src/Qir/Runtime/Microsoft.Quantum.Qir.Runtime.nuspec' -ForcePrerelease

if (-not $all_ok) {
    throw "At least one project failed to pack. Check the logs."
}
