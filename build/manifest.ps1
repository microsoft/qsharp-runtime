# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

& "$PSScriptRoot/set-env.ps1"

@{
    Packages = @(
        "Microsoft.Quantum.CsharpGeneration",
        "Microsoft.Quantum.Development.Kit",
        "Microsoft.Quantum.QSharp.Core",
        "Microsoft.Quantum.Runtime.Core",
        "Microsoft.Quantum.Simulators",
        "Microsoft.Quantum.Xunit"
    );
    Assemblies = @(
        ".\src\simulation\CsharpGeneration\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.CsharpGeneration.dll",
        ".\src\simulation\CsharpGeneration.App\bin\$Env:BUILD_CONFIGURATION\netcoreapp3.1\Microsoft.Quantum.CsharpGeneration.App.dll",
        ".\src\simulation\CsharpGeneration.App\bin\$Env:BUILD_CONFIGURATION\netcoreapp3.1\Microsoft.Quantum.RoslynWrapper.dll",
        ".\src\simulation\Core\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Runtime.Core.dll",
        ".\src\simulation\QsharpCore\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.QSharp.Core.dll",
        ".\src\simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulation.Common.dll",
        ".\src\simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulation.QCTraceSimulatorRuntime.dll",
        ".\src\simulation\Simulators\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Simulation.Simulators.dll",
        ".\src\Xunit\bin\$Env:BUILD_CONFIGURATION\netstandard2.1\Microsoft.Quantum.Xunit.dll"
    ) | ForEach-Object { Get-Item (Join-Path $PSScriptRoot (Join-Path ".." $_)) };
} | Write-Output; 