# Copyright (c) Microsoft Corporation. All rights reserved.
# Licensed under the MIT License.

$ErrorActionPreference = 'Stop'

Write-Host "Setting up build environment variables"

If ($Env:BUILD_BUILDNUMBER -eq $null) { $Env:BUILD_BUILDNUMBER ="0.0.1.0" }
Write-Host "BUILD_BUILDNUMBER: $Env:BUILD_BUILDNUMBER"

If ($Env:BUILD_CONFIGURATION -eq $null) { $Env:BUILD_CONFIGURATION ="Debug" }
Write-Host "BUILD_CONFIGURATION: $Env:BUILD_CONFIGURATION"

If ($Env:BUILD_VERBOSITY -eq $null) { $Env:BUILD_VERBOSITY ="m" }
Write-Host "BUILD_VERBOSITY: $Env:BUILD_VERBOSITY"

If ($Env:ASSEMBLY_VERSION -eq $null) { $Env:ASSEMBLY_VERSION ="$Env:BUILD_BUILDNUMBER" }
Write-Host "ASSEMBLY_VERSION: $Env:ASSEMBLY_VERSION"

If ($Env:PYTHON_VERSION -eq $null) { $Env:PYTHON_VERSION = "${Env:ASSEMBLY_VERSION}a1" }
Write-Host "PYTHON_VERSION: $Env:PYTHON_VERSION"

If ($Env:NUGET_VERSION -eq $null) { $Env:NUGET_VERSION ="0.0.1-alpha" }
Write-Host "NUGET_VERSION: $Env:NUGET_VERSION"


If ($Env:ENABLE_NATIVE -ne "false") {
    If ($Env:NATIVE_SIMULATOR -eq $null) {
        $Env:NATIVE_SIMULATOR = (Join-Path $PSScriptRoot "..\src\Simulation\Native\build\drop")
    }
    Write-Host "NATIVE_SIMULATOR: $Env:NATIVE_SIMULATOR"
}

if ($Env:ENABLE_QIRRUNTIME -ne "false") {
    If ($Env:QIR_DROPS -eq $null) {
        $Env:QIR_DROPS = (Join-Path $PSScriptRoot "../src/Qir/drops")
    }
    Write-Host "QIR_DROPS: $Env:QIR_DROPS"
}

If ($Env:DROPS_DIR -eq $null) { $Env:DROPS_DIR =  [IO.Path]::GetFullPath((Join-Path $PSScriptRoot "..\drops")) }
Write-Host "DROPS_DIR: $Env:DROPS_DIR"

if ($Env:DROP_NATIVE -eq $null) {
    $Env:DROP_NATIVE = (Join-Path $PSScriptRoot "..")
}
Write-Host "DROP_NATIVE: $Env:DROP_NATIVE"


If ($Env:INTERNAL_TOOLS_OUTDIR -eq $null) { $Env:INTERNAL_TOOLS_OUTDIR =  (Join-Path $Env:DROPS_DIR "internal_tools") }
If (-not (Test-Path -Path $Env:INTERNAL_TOOLS_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:INTERNAL_TOOLS_OUTDIR) }
Write-Host "INTERNAL_TOOLS_OUTDIR: $Env:INTERNAL_TOOLS_OUTDIR"

If ($Env:NUGET_OUTDIR -eq $null) { $Env:NUGET_OUTDIR =  (Join-Path $Env:DROPS_DIR "nugets") }
If (-not (Test-Path -Path $Env:NUGET_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:NUGET_OUTDIR) }
Write-Host "NUGET_OUTDIR: $Env:NUGET_OUTDIR"

If ($Env:CRATE_OUTDIR -eq $null) { $Env:CRATE_OUTDIR =  (Join-Path $Env:DROPS_DIR "crates") }
If (-not (Test-Path -Path $Env:CRATE_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:CRATE_OUTDIR) }
Write-Host "CRATE_OUTDIR: $Env:CRATE_OUTDIR"

If ($Env:WHEEL_OUTDIR -eq $null) { $Env:WHEEL_OUTDIR =  (Join-Path $Env:DROPS_DIR "wheels") }
If (-not (Test-Path -Path $Env:WHEEL_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:WHEEL_OUTDIR) }
Write-Host "WHEEL_OUTDIR: $Env:WHEEL_OUTDIR"

If ($Env:DOCS_OUTDIR -eq $null) { $Env:DOCS_OUTDIR =  (Join-Path $Env:DROPS_DIR "docs") }
If (-not (Test-Path -Path $Env:DOCS_OUTDIR)) { [IO.Directory]::CreateDirectory($Env:DOCS_OUTDIR) }
Write-Host "DOCS_OUTDIR: $Env:DOCS_OUTDIR"


Get-ChildItem @(
    "Env:\DROPS_DIR",
    "Env:\DROP_NATIVE",
    "Env:\NUGET_OUTDIR",
    "Env:\CRATE_OUTDIR",
    "Env:\WHEEL_OUTDIR",
    "Env:\DOCS_OUTDIR"
 ) | Format-Table