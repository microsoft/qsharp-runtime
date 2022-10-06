# Copyright (c) Microsoft Corporation.
# Licensed under the MIT License.

#Requires -PSEdition Core

Properties {
    $IsCI = "$Env:TF_BUILD" -ne "" -or "$Env:CI" -eq "true";
}

task set-env -description "Setting up build environment variables" {
    If ($Env:BUILD_BUILDNUMBER -eq $null) { $Env:BUILD_BUILDNUMBER = "0.0.1.0" }
    If ($Env:BUILD_CONFIGURATION -eq $null) { $Env:BUILD_CONFIGURATION = "Debug" }
    If ($Env:BUILD_VERBOSITY -eq $null) { $Env:BUILD_VERBOSITY = "m" }
    If ($Env:ASSEMBLY_VERSION -eq $null) { $Env:ASSEMBLY_VERSION = "$Env:BUILD_BUILDNUMBER" }
    If ($Env:PYTHON_VERSION -eq $null) { $Env:PYTHON_VERSION = "${Env:ASSEMBLY_VERSION}a1" }
    If ($Env:NUGET_VERSION -eq $null) { $Env:NUGET_VERSION = "0.0.1-alpha" }

    If (($Env:ENABLE_NATIVE -ne "false") -and ($Env:NATIVE_SIMULATOR -eq $null) ) {
        $Env:NATIVE_SIMULATOR = (Join-Path $PSScriptRoot "..\src\Simulation\Native\build\drop")
    }

    if ($Env:ENABLE_QIRRUNTIME -ne "false" -and $Env:QIR_DROPS -eq $null) {
        $Env:QIR_DROPS = (Join-Path $PSScriptRoot "../src/Qir/drops")
    }

    If ($Env:DROPS_DIR -eq $null) { $Env:DROPS_DIR = [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\drops")) }
    if ($Env:DROP_NATIVE -eq $null) {
        $Env:DROP_NATIVE = (Join-Path $PSScriptRoot "..")
    }

    If ($Env:INTERNAL_TOOLS_OUTDIR -eq $null) { $Env:INTERNAL_TOOLS_OUTDIR = (Join-Path $Env:DROPS_DIR "internal_tools") }
    If (-not (Test-Path -Path $Env:INTERNAL_TOOLS_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:INTERNAL_TOOLS_OUTDIR) }
    If ($Env:NUGET_OUTDIR -eq $null) { $Env:NUGET_OUTDIR = (Join-Path $Env:DROPS_DIR "nugets") }
    If (-not (Test-Path -Path $Env:NUGET_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:NUGET_OUTDIR) }

    If ($Env:CRATE_OUTDIR -eq $null) { $Env:CRATE_OUTDIR = (Join-Path $Env:DROPS_DIR "crates") }
    If (-not (Test-Path -Path $Env:CRATE_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:CRATE_OUTDIR) }

    If ($Env:WHEEL_OUTDIR -eq $null) { $Env:WHEEL_OUTDIR = (Join-Path $Env:DROPS_DIR "wheels") }
    If (-not (Test-Path -Path $Env:WHEEL_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:WHEEL_OUTDIR) }

    If ($Env:DOCS_OUTDIR -eq $null) { $Env:DOCS_OUTDIR = (Join-Path $Env:DROPS_DIR "docs") }
    If (-not (Test-Path -Path $Env:DOCS_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:DOCS_OUTDIR) }

    $env:BUILD_PLATFORM = "win-x64"
    if ($IsLinux) {
        $env:BUILD_PLATFORM = "linux-x64"
    }
    elseif ($IsMacOS) {
        $env:BUILD_PLATFORM = "osx-x64"
    }

    Get-ChildItem -Path Env:/* -Include @(
        "BUILD_BUILDNUMBER",
        "BUILD_CONFIGURATION",
        "BUILD_VERBOSITY",
        "BUILD_PLATFORM",
        "ASSEMBLY_VERSION",
        "PYTHON_VERSION",
        "NUGET_VERSION",
        "NATIVE_SIMULATOR",
        "QIR_DROPS",
        "DROPS_DIR",
        "DROP_NATIVE",
        "INTERNAL_TOOLS_OUTDIR",
        "NUGET_OUTDIR",
        "CRATE_OUTDIR",
        "WHEEL_OUTDIR",
        "DOCS_OUTDIR"
    ) | Format-Table | Out-String | Write-Host

    Get-ChildItem @(
        "Env:\DROPS_DIR",
        "Env:\DROP_NATIVE",
        "Env:\NUGET_OUTDIR",
        "Env:\CRATE_OUTDIR",
        "Env:\WHEEL_OUTDIR",
        "Env:\DOCS_OUTDIR"
    ) | Format-Table

    Write-Host "PATH:"
    Write-Host "$Env:PATH"
}
