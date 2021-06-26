# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

<#
    .SYNOPSIS
        Provides the list of artifacts (Packages and Assemblies) generated by this repository.
    
    .PARAMETER OutputFormat
        Specifies if the output of this script should be a hashtable with the artifacts
        as strings with the absolute path (AbsolutePath) or FileInfo structures.
#>
param(
    [ValidateSet('FileInfo','AbsolutePath')]
    [string] $OutputFormat = 'FileInfo'
);


& "$PSScriptRoot/set-env.ps1"

$artifacts = @{
    Packages = @(
        "Microsoft.Azure.Quantum.Client",
        "Microsoft.Quantum.AutoSubstitution",
        "Microsoft.Quantum.EntryPointDriver",
        "Microsoft.Quantum.QSharp.Core",
        "Microsoft.Quantum.Type1.Core",
        "Microsoft.Quantum.Type2.Core",
        "Microsoft.Quantum.Type3.Core",
        "Microsoft.Quantum.QSharp.Foundation"
        "Microsoft.Quantum.Runtime.Core",
        "Microsoft.Quantum.Simulators",
        "Microsoft.Quantum.Xunit"
    ) | ForEach-Object { Join-Path $Env:NUGET_OUTDIR "$_.$Env:NUGET_VERSION.nupkg" };

    Assemblies = @(
        ".\src\Azure\Azure.Quantum.Client\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Azure.Quantum.Client.dll",
        ".\src\Simulation\AutoSubstitution\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.AutoSubstitution.dll",
        ".\src\Simulation\Core\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Runtime.Core.dll",
        ".\src\Simulation\EntryPointDriver\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.EntryPointDriver.dll",
        ".\src\Simulation\QSharpCore\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.QSharp.Core.dll",
        ".\src\Simulation\Type1Core\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Type1.Core.dll",
        ".\src\Simulation\Type2Core\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Type2.Core.dll",
        ".\src\Simulation\Type3Core\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Type3.Core.dll",
        ".\src\Simulation\QSharpFoundation\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.QSharp.Foundation.dll",
        ".\src\Simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulation.Common.dll",
        ".\src\Simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.dll",
        ".\src\Simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulators.dll",
        ".\src\Xunit\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Xunit.dll"
    ) | ForEach-Object { Join-Path $PSScriptRoot (Join-Path ".." $_) };
    
    Native = @(
        ".\src\Simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulator.Runtime.dll",
        ".\src\Qir\Runtime\bin\$Env:BUILD_CONFIGURATION\bin\Microsoft.Quantum.Qir.QSharp.Core.dll",
        ".\src\Qir\Runtime\bin\$Env:BUILD_CONFIGURATION\bin\Microsoft.Quantum.Qir.QSharp.Foundation.dll",
        ".\src\Qir\Runtime\bin\$Env:BUILD_CONFIGURATION\bin\Microsoft.Quantum.Qir.Runtime.dll",
        ".\src\Qir\Runtime\bin\$Env:BUILD_CONFIGURATION\bin\Microsoft.Quantum.Qir.Tracer.dll"
    ) | ForEach-Object { Join-Path $PSScriptRoot (Join-Path ".." $_) };
}

if ($OutputFormat -eq 'FileInfo') {
    $artifacts.Packages = $artifacts.Packages | ForEach-Object { Get-Item $_ };
    $artifacts.Assemblies = $artifacts.Assemblies | ForEach-Object { Get-Item $_ };
    $artifacts.Native = $artifacts.Native | ForEach-Object { Get-Item $_ };
}
    
$artifacts | Write-Output;
